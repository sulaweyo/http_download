# This type allows dowloads of files via plain ruby
#
require 'puppet'
require 'net/http'
require 'uri'

Puppet::Type.type(:download).provide(:ruby) do
  def fetch(uri_str, limit = 10)
    raise ArgumentError, 'too many HTTP redirects' if limit == 0
    ssl = resource[:use_ssl]
    if !ssl and uri_str.start_with? 'https'
      ssl = true
    end
    uri = URI(uri_str)
    Net::HTTP.start(uri.host, uri.port) do |http|
      if (ssl)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end
      request = Net::HTTP::Get.new uri.request_uri
      if nil != resource[:user] and nil != resource[:pass]
        request.basic_auth(resource[:user], resource[:pass])
      end
      http.request request do |response|

        case response
        when Net::HTTPRedirection then
          location = response['location']
          Puppet.notice("redirected to #{location}")
          fetch(location, limit - 1)
        when Net::HTTPForbidden then
          raise SecurityError, 'access denied'
        when Net::HTTPSuccess then
          open resource[:dest], 'wb' do |io|
            response.read_body do |chunk|
              io.write chunk
            end
          end
        else
          raise "undefined state => #{response.code} - #{response.message}"
        end
      end
    end
  end

  def download
    success = false
    for retries in 1..3
      begin
        fetch(resource[:uri])
        success = true
      rescue SecurityError => s
        Puppet.crit("SecurityError -> \n#{s.inspect}")
        break
      rescue ArgumentError => a
        Puppet.crit("ArgumentError -> \n#{a.inspect}")
        break
      rescue IOError => eio
        Puppet.crit("IO Exception during http download -> \n#{eio.inspect}")
      rescue Net::HTTPError => ehttp
        Puppet.crit("HTTP Exception during http download -> \n#{ehttp.inspect}")
      rescue StandardError => e
        Puppet.crit("Exception during http download -> \n#{e.inspect}\n#{e.backtrace}")
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