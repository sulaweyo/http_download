# Type: http_download::download
#
# This is wrapper around 'download' that sets ownership and mode of downloaded file
#
define http_download::download(
    $uri = undef,
    $dest = undef,
    $backupsuffix = undef,
    $force = undef,
    $use_ssl = undef,
    $user = undef,
    $pass = undef,
    $proxy_host = undef,
    $proxy_port = undef,
    $proxy_user = undef,
    $proxy_pass = undef,
    
    $owner = undef,
    $group = undef,
    $mode = undef,
    
) {

  if ($uri == undef) {
    $urival = $name
  } else {
    $urival = $uri
  }

  download { "$name":
    uri => $urival,
    dest => $dest,
    backupsuffix => $backupsuffix,
    force => $force,
    use_ssl => $use_ssl,
    user => $user,
    pass => $pass,
    proxy_host => $proxy_host,
    proxy_port => $proxy_port,
    proxy_user => $proxy_user,
    proxy_pass => $proxy_pass,
  }

  file { "$name":
    ensure => file,
    path => $dest,
    owner => $owner,
    group => $group,
    mode => $mode,
    require => Download["$name"],
  }

}
