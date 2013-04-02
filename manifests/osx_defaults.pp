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
    'currentHost' => ' -currentHost',
    undef         => '',
    default       => " -host ${host}"
  }

  case $ensure {
    present: {
      if ($domain == undef) or ($key == undef) or ($value == undef) {
        fail('Cannot ensure present without domain, key, and value attributes')
      }

      $cmd = $type ? {
        undef   => "${defaults_cmd}${host_option} write ${domain} '${key}' '${value}'",
        default => "${defaults_cmd}${host_option} write ${domain} '${key}' -${type} '${value}'"
      }

      exec { "osx_defaults write ${host} ${domain}:${key}=>${value}":
        command => $cmd,
        unless  => "${defaults_cmd}${host_option} read ${domain} '${key}' && (${defaults_cmd}${host_option} read ${domain} '${key}' | awk '{ exit \$0 != \"${value}\" }')",
        user    => $user
      }
    } # end present

    default: {
      exec { "osx_defaults delete ${host} ${domain}:${key}":
        command => "${defaults_cmd}${host_option} delete ${domain} '${key}'",
        onlyif  => "${defaults_cmd}${host_option} read ${domain} | grep '${key}'",
        user    => $user
      }
    } # end default
  }
}
