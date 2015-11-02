class nagiosslave::nagios-monitor {
    package { [ nagios3 ]: ensure => installed, }

    service { nagios3:
        ensure => running,
        enable => true,
        #subscribe => File[$nagios_cfgdir],
        require => Package[nagios3],
    }

  file { '/etc/nagios3/nagios.cfg':
    owner  => 'nagios',
    source => 'puppet:///modules/nagiosslave/nagios.cfg',
    notify => Exec['update-nagios-owner'],
  }

  file { '/etc/nagios3/commands.cfg':
    owner  => 'nagios',
    source => 'puppet:///modules/nagiosslave/commands.cfg',
    notify => Exec['update-nagios-owner'],
  }

  exec { 'update-nagios-owner' :
    command      => '/bin/chown nagios /etc/nagios3/resource.d/*',
    refreshonly  => true,
    notify       => Service["nagios3"],
  }


  # Be sure to include this directory in your nagios.cfg
  # with the cfg_dir directive

  file { resource-d:
    path => '/etc/nagios3/resource.d',
    ensure => directory,
    owner => 'nagios',
    require => Package[nagios3],
  }

  # collect resources and populate /etc/nagios3/nagios_*.cfg
  Nagios_host <<| tag == "$domain" |>>
  Nagios_service <<| tag == "$domain" |>>
}

