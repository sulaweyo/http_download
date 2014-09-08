# Class: http_download
#
class http_download {

  #this is just a test for the class
  if $::kernel == 'linux' {
    download {'test file 1':
      uri  => 'http://downloads.sourceforge.net/project/sevenzip/7-Zip/9.22/7z922.exe?r=http%3A%2F%2Fsourceforge.net%2Fdirectory%2Fsecurity-utilities%2F&ts=1410154697&use_mirror=heanet',
      dest => '/tmp/7z922.exe'
    }
  } else {       
    download {'test file 1':
      uri     => 'http://downloads.sourceforge.net/project/sevenzip/7-Zip/9.22/7z922.exe?r=http%3A%2F%2Fsourceforge.net%2Fdirectory%2Fsecurity-utilities%2F&ts=1410154697&use_mirror=heanet',
      dest    => 'c:\\7z922.exe',
    }
  }
}
