#
# nagios slave module
#

class nagiosslave {
  case $::operatingsystem {
    centos: {
      $nagios_cfgdir = '/etc/nagios'
      include nagiosslave::centos
    }
    debian: {
      $nagios_cfgdir = '/etc/nagios3'
      include nagiosslave::debian
    }
    ubuntu: {
      $nagios_cfgdir = '/etc/nagios3'
      include nagiosslave::debian
      include nagiosslave::ubuntu
    }
    windows: {
      include nagiosslave::windows
    }
    default: {
      fail("No such operatingsystem: $::{operatingsystem} not defined")
    }
  }
}
