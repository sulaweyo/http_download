# Class: http_download
#
class http_download {
  # this is just a test for the module
  if $::kernel == 'linux' {
    $target = '/tmp/'
  } else {
    $target = 'C:/'
  }

  download { 'test file basic':
    uri  => 'http://www.7-zip.org/a/7z920-x64.msi',
    dest => "${target}7z920-x64.msi",
  }

  download { 'test https and large file':
    uri  => 'https://downloads.mariadb.org/f/mariadb-10.0.17/bintar-linux-glibc_214-x86_64/mariadb-10.0.17-linux-glibc_214-x86_64.tar.gz?serve',
    dest => "${target}mariadb-10.0.17-linux-glibc_214-x86_64.tar.gz",
  }

  download { 'test basic auth':
    uri  => 'http://brunmayr.org/test/README.md',
    dest => "${target}README.md",
    user => 'test',
    pass => 'Basic_Auth1'
  }
}
