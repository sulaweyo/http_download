# This type allows dowloads of files via plain ruby
#
require 'puppet'
require 'net/http'
require 'uri'

Puppet::Type.type(:download).provide(:ruby) do
  def download
    success = false
    access_denied = false
    for retries in 1..3
      begin
        Puppet.debug("HTTP download uri is ... '#{resource[:uri]}'")
        myURI = URI(resource[:uri])
        ssl = resource[:use_ssl]
          if !ssl and resource[:uri].start_with? 'https'
            ssl = true
          end
        http = Net::HTTP.new(myURI.host, myURI.port)
        if (ssl)
          http.use_ssl = true
          http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        end
        req = Net::HTTP::Get.new(myURI.path)
        if nil != resource[:user] and nil != resource[:pass]
          req.basic_auth(resource[:user], resource[:pass])
        end
        resp = http.request(req)
        redirects = 0
        while resp.code == '301' || resp.code == '302'
          Puppet.debug("Redirect to #{resp.header['location']}")
          myURI = URI.parse(resp.header['location'])
          if (ssl)
            http.use_ssl = true
            http.verify_mode = OpenSSL::SSL::VERIFY_NONE
          end
          req = Net::HTTP::Get.new(myURI.path)
          if nil != resource[:user] and nil != resource[:pass]
            req.basic_auth(resource[:user], resource[:pass])
          end
          resp = http.request(req)
          redirects += 1
          if (redirects > 10)
            raise 'too many redirects'
          end
        end
        if resp.code == '200'
          Puppet.debug('Starting download...')
          file = File.open(resource[:dest], "wb")
          http.request(req) do |response|
            response.read_body do |segment|
              file.write(segment)
            end
          end
          if http.started?
            http.finish
          end
          success = true
        elsif resp.code == '403'
          access_denied = true
          Puppet.alert("Server returned code 403: '#{resp.message}'")
        end
      rescue IOError => eio
        Puppet.crit("IO Exception during http download -> \n#{eio.inspect}")
      rescue Net::HTTPError => ehttp
        Puppet.crit("HTTP Exception during http download -> \n#{ehttp.inspect}")
      rescue StandardError => e
        Puppet.crit("Exception during http download -> \n#{e.inspect}\n#{e.backtrace}")
      ensure
        if (nil != file)
          file.close
        end
      end
      if success
        break
      else
        Puppet.info("Download failed - try again...")
      end
      if access_denied
        break
      end
    end
    return success
  end

  def exists?
    false
  end

  def destroy
    true
  end

  def create
    succ = download()
    if !succ
      Puppet.crit("HTTP download of '#{resource[:uri]}' failed!")
    end
    succ
  end
end