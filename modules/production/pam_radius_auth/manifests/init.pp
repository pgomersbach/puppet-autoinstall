# $pam_radius_servers, $pam_radius_secret, and $pam_radius_timeout should
# be modified for your environment. See the README for more information.
#
class pam_radius_auth($pam_radius_servers = [ "192.168.2.134",
                                              "192.168.10.9" ],
                      $pam_radius_secret  = "secret",
                      $pam_radius_timeout = '3' )
{
  # Distribution check
  case $operatingsystem {
    centos, redhat: {
      $supported     = true
      $pkg           = [ "pam_radius", "pam_script" ]
      $conf          = "/etc/pam_radius.conf"
      $pam_sshd_conf = "pam_sshd_el"
      $pam_sudo_conf = "pam_sudo_el"
    }
    ubuntu, debian: {
      $supported     = true
      $pkg           = [ "libpam-radius-auth", "libpam-script" ]
      $conf          = "/etc/pam_radius_auth.conf"
      $pam_sshd_conf = "pam_sshd_deb"
      $pam_sudo_conf = "pam_sudo_deb"
    }
    default: {
      $supported = false
      notify { "pam_radius_auth module not supported on ${operatingsystem}":}
    }
  }

  if ($supported == true) {
    # Package installation
    # On Redhat/CentOS, pam_radius is in the EPEL repo
    # On Debian/Ubuntu, libpam-radius-auth is included in main
    package { $pkg:
      ensure  => present,
    }

    file { $conf:
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => 0600,
      content => template("pam_radius_auth/pam_radius.conf.erb"),
      require => Package[$pkg],
    }

    file { "/usr/share/libpam-script/pam_script_auth":
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => 0755,
      source => "puppet:///modules/pam_radius_auth/pam_script_auth",
      require => Package[$pkg],
    }


    # Copy sshd and sudo files to /etc/pam.d
    file { "/etc/pam.d/sshd":
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => 0644,
      source  => "puppet:///modules/pam_radius_auth/${pam_sshd_conf}",
      require => [ Package[$pkg], File[$conf] ],
    }

    file { "/etc/pam.d/sudo":
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => 0644,
      source  => "puppet:///modules/pam_radius_auth/${pam_sudo_conf}",
      require => [ Package[$pkg], File[$conf] ],
    }
  }
}
