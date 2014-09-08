# This type allows dowloads of files via plain ruby 
#
require 'puppet'
require 'net/http'

Puppet::Type.type(:download).provide(:ruby) do

  def download
    begin
      Puppet.debug("Download URI is #{resource[:uri]}")
      Puppet.debug("Destination is #{resource[:dest]}")
      uri = URI(resource[:uri])
      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Get.new(uri.request_uri)
      Puppet.debug("Download host is #{uri.host}")
      Puppet.debug("Download uri is #{uri.request_uri}")
      http = Net::HTTP.start(uri.host)
      resp = http.request_get(uri.request_uri)
      Puppet.debug("Response code #{resp.code}")
      redirects = 0
      while resp.code == '301' || resp.code == '302' 
        Puppet.debug("Redirect response is #{resp.header['location']}")
        newUri = URI.parse(resp.header['location'])
        http = Net::HTTP.start(newUri.host)
        resp = http.request_get(newUri.request_uri)
        Puppet.debug("Redirect response code #{resp.code}")
        redirects += 1
        if (redirects > 10)
          raise 'too many redirects'
        end
      end
      if resp.code == '200'
        file = File.open(resource[:dest], "wb")
        http.request_get(newUri.request_uri) do |response|
          response.read_body do |segment|
            file.write(segment)
          end
        end
      end
    rescue IOError => eio
      Puppet.crit("IO Exception during http download -> \n#{eio.inspect}")
    rescue Net::HTTPError => ehttp
      Puppet.crit("HTTP Exception during http download -> \n#{ehttp.inspect}")
    rescue StandardError => e
      Puppet.crit("Exception during http download -> \n#{e.inspect}")
    ensure
      http.finish
      file.close
    end
  end
  

  def exists?
    Puppet.debug('Exists was called for download')
    false
  end

  def destroy
    Puppet.debug('Destroy was called for download')
    true
  end

  def create
    download()
  end
end