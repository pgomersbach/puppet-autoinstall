# == Class: clean
#
# Full description of class clean here.
#
# === Parameters
#
# Document parameters here.
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
# === Variables
#
# Here you should define a list of variables that this module would require.
#
# [*sample_variable*]
#   Explanation of how this variable affects the funtion of this class and if it
#   has a default. e.g. "The parameter enc_ntp_servers must be set by the
#   External Node Classifier as a comma separated list of hostnames." (Note,
#   global variables should not be used in preference to class parameters  as of
#   Puppet 2.6.)
#
# === Examples
#
#  class { clean:
#    servers => [ 'pool.ntp.org', 'ntp.local.company.com' ]
#  }
#
# === Authors
#
# Author Name <author@domain.com>
#
# === Copyright
#
# Copyright 2011 Your name here, unless otherwise noted.
#
class clean {
  package { localepurge: ensure => installed }
  exec { "/usr/bin/apt-get -y clean":
    logoutput => true,
    require => Package[localepurge],
  }
  exec { "/usr/bin/apt-get -y autoclean":
    logoutput => true,
    require => Package[localepurge],
  }
  exec { "/usr/sbin/localepurge":
    logoutput => true,
    require => Package[localepurge],
  }
  exec { "/bin/rm -rf /usr/share/doc/":
    logoutput => true,
  }
  exec { "/bin/rm -rf /usr/share/doc-base/":
    logoutput => true,
  }
  exec { "/usr/bin/dpkg --purge man-db manpages":
    logoutput => true,
  }
  exec { "/bin/rm -rf /usr/share/man/":
    logoutput => true,
  }
  exec { "/bin/rm -f /var/log/*.gz":
    logoutput => true,
  }

}
