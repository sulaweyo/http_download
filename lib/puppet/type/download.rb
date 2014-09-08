# This type holds the code to upload the user attributes
#
#
require "puppet"

Puppet::Type.newtype(:download) do
  desc <<-EOS
    This type allows to do downloads via ruby without the need for any localy provided executable.
   
    Example:
  
          download { 'my download':
            uri  => 'http://www.example.com/download/example.txt',
            dest => '/tmp/example.txt'
          }
  
  EOS

  ensurable do
    defaultvalues
    defaultto :present
  end
  
  newparam(:name, :namevar => true) do
    desc "The name for the download."
  end
  
  newparam(:uri) do
    desc "The uri of the file to download."
  end
    
  newparam(:dest) do
    desc "The destination file. Make sure the path to this file exists!"
  end
end