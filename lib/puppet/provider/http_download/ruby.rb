# This type allows dowloads of files via plain ruby 
#
require 'puppet'
require 'net/http'

Puppet::Type.type(:http_download).provide(:ruby) do

  def download
    begin
      uri = URI(resource[:uri])
      Net::HTTP.request_get(uri) do |resp|
        open(resource[:dest], "wb") do |file|
          resp.read_body do |segment|
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
    end
  end
  

  def exists?
    false
  end

  def destroy
    true
  end

  def create
    download()
  end
end