# == Class: win_snmp
#
# Full description of class win_snmp here.
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
#  class { win_snmp:
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
class win_snmp {

  if $osfamily == "windows" {
    $server_to_mon=$fqdn
    @@file { "/tmp/$server_to_mon.base.conf":
      tag => "$domain.base.conf",
      content => template("nagiosslave/windows.erb"),
    }


    if ( $kernelmajversion == "6.0" ) or ( $kernelmajversion == "6.1" ) {
      dism { 'SNMP':
        ensure => present,
      }

    registry::value { 'systemContact':
      key     => 'HKLM\System\CurrentControlSet\services\SNMP\Parameters\RFC1156Agent',
      value   => sysContact,
      data    => $snmp_contact,
      notify  => Exec["StopSNMP"],
    }

    registry::value { 'systemLocation':
      key   => 'HKLM\System\CurrentControlSet\services\SNMP\Parameters\RFC1156Agent',
      value => sysLocation,
      data  => $snmp_location,
      notify  => Exec["StopSNMP"],
    }

    registry::value { 'Comunity':
      key   => 'HKLM\System\CurrentControlSet\services\SNMP\Parameters\ValidCommunities',
      value => "public",
      type => "dword",
      data  => "4",
      notify  => Exec["StopSNMP"],
    }

    registry::value { 'servers':
      key   => 'HKLM\System\CurrentControlSet\services\SNMP\Parameters\PermittedManagers',
      value => "1",
      data  => "$snmp_server",
      notify  => Exec["StopSNMP"],
    }

    exec { 'StopSNMP':
      command => "net stop SNMP",
      path => $::path,
      provider => windows,
      refreshonly => true,
      notify  => Exec["StartSNMP"],
    }

    exec { 'StartSNMP':
      command => "net start SNMP",
      path => $::path,
      provider => windows,
      refreshonly => true,
    }

    service { 'SNMP':
      ensure => 'running',
      enable => true,
      require => Dism['SNMP'],
    }
    }
  }
}
