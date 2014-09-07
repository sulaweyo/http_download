# This type holds the code to upload the user attributes
#
#
require "puppet"

Puppet::Type.newtype(:http_download) do
  desc <<-EOS
    This type allows to do downloads via ruby without the need for any localy provided executable.
   
    Example:
  
          file_line { 'my download':
            uri  => 'http://www.example.com/download/example.txt',
            dest => '/tmp/example.txt'
          }
          file_line { 'http://example.com/download/example.txt':
            dest => 'C:\\tmp\example.txt',
          }
  
  EOS

  newparam(:name, :namevar => true) do
    desc "The name or uri for the download."
  end
  
  newparam(:uri) do
    desc "The uri of the file to download. Defaults to the name if not specified!"
    defaultto resource[:name]
  end
    
  newparam(:dest) do
    desc "The destination file. Make sure the path to this file exists!"
  end
end