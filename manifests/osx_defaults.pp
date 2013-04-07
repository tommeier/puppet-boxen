# Public: Set a system config option with the OS X defaults system

define boxen::osx_defaults(
  $ensure = 'present',
  $host   = undef,
  $domain = undef,
  $key    = undef,
  $value  = undef,
  $user   = undef,
  $type   = undef,
) {
  $defaults_cmd = '/usr/bin/defaults'

  $host_option = $host ? {
    'currentHost' => '-currentHost',
    undef         => undef,
    default       => [ '-host', $host ]
  }

  if $host_option == undef {
    $default_cmds = [ $defaults_cmd ]
  } else {
    $default_cmds = [ $defaults_cmd, $host_option ]
  }

  case $ensure {
    present: {
      if ($domain == undef) or ($key == undef) or ($value == undef) {
        fail('Cannot ensure present without domain, key, and value attributes')
      }

      $cmd = $type ? {
        undef   => shellquote($default_cmds, 'write', $domain, $key, $value),
        default => shellquote($default_cmds, 'write', $domain, $key, "-${type}", $value)
      }

      $read_cmd = shellquote($default_cmds, 'read', $domain, $key)

      exec { "osx_defaults write ${host} ${domain}:${key}=>${value}":
        command => $cmd,
        unless  => "${read_cmd} && (${read_cmd} | awk '{ exit \$0 != \"${value}\" }')",
        user    => $user
      }
    } # end present

    default: {
      $list_cmd   = shellquote($default_cmds, 'read', $domain)
      $key_search = shellquote('grep', $key)

      exec { "osx_defaults delete ${host} ${domain}:${key}":
        command => shellquote($default_cmds, 'delete', $domain, $key),
        onlyif  => "${list_cmd} | ${key_search}",
        user    => $user
      }
    } # end default
  }
}
