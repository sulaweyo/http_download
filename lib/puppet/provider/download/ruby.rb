# This type allows dowloads of files via plain ruby 
#
require 'puppet'
require 'net/http'
require 'uri'

Puppet::Type.type(:download).provide(:ruby) do

  def download
    begin
      Puppet.debug("HTTP download uri is ... '#{resource[:uri]}'")
      s3url = URI(resource[:uri])
      http = Net::HTTP.new(s3url.host, s3url.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      resp = http.request_get(s3url.request_uri)
      redirects = 0
      while resp.code == '301' || resp.code == '302' 
        Puppet.debug("Redirect to #{resp.header['location']}")
        s3url = URI.parse(resp.header['location'])
        http = Net::HTTP.start(s3url.host, s3url.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        resp = http.request_get(s3url.request_uri)
        redirects += 1
        if (redirects > 10)
          raise 'too many redirects'
        end
      end
      if resp.code == '200'
        Puppet.debug('Starting download...')
        file = File.open(resource[:dest], "wb")
        http.request_get(s3url.request_uri) do |response|
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
      Puppet.crit("Exception during http download -> \n#{e.inspect}\n#{e.backtrace}")
    ensure
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