# http_download

## Overview

This module contains a puppet type that allows http downloads directly via ruby. No additional executables are needed.

## Class: http_download

The class just shows how to use this type by downloading a file.

### Sample Usage

```puppet
download {'test file 1':
    uri  => 'http://downloads.sourceforge.net/project/sevenzip/7-Zip/9.22/7z922.exe?r=http%3A%2F%2Fsourceforge.net%2Fdirectory%2Fsecurity-utilities%2F&ts=1410154697&use_mirror=heanet',
    dest => '/tmp/7z922.exe'
}

download { 'my sll and basic auth download':
    uri  => 'https://www.example.com/download/example.txt',
    dest => '/tmp/example.txt',
    user => 'user',
    pass => 'pass'
}
```

## Supported OSes

As it's written in plain ruby all OS that can run Puppet should be able to use it.
I have tested it on different Windows versions and Debian based distros so far. 