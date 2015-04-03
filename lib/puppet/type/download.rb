# This type holds the code to upload the user attributes
#
#
require 'puppet'
require 'puppet/parameter/boolean'

Puppet::Type.newtype(:download) do
  desc <<-EOS
    This type allows to do downloads via ruby without the need for any localy provided executable.
   
    Example:
  
          download { 'my download':
            uri  => 'http://www.example.com/download/example.txt',
            dest => '/tmp/example.txt'
          }
          
          download { 'my sll and basic auth download':
           uri  => 'https://www.example.com/download/example.txt',
           dest => '/tmp/example.txt',
           user => 'user',
           pass => 'pass'
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

  newparam(:use_ssl, :boolean => true, :parent => Puppet::Parameter::Boolean) do
    desc "Use SSL for the transfer? If the URL starts with https this is set automatically."
    defaultto :false
    newvalues(:true, :false)
  end

  newparam(:user) do
    desc "A user to use for basic authentication."
  end

  newparam(:pass) do
    desc "A pass to use for basic authentication."
  end
end