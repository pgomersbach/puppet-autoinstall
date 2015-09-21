class nagiosslave::windows {
  if $::osfamily == 'windows' {
  File { source_permissions => ignore }
  include concat::setup

    file { 'Nagios_directory':
      ensure => directory,
      path   => "C:\\Program Files\\Nagios",
    }

    file { 'NRDS_directory':
      ensure  => directory,
      path    => "C:\\Program Files\\Nagios\\NRDS_Win",
      require => File[ 'Nagios_directory' ],
    }

    file { 'NRDS_directory_logs':
      ensure  => directory,
      path    => "C:\\Program Files\\Nagios\\NRDS_Win\\logs",
      require => File[ 'NRDS_directory' ],
    }
  
    file { 'C:\Program Files\Nagios\NRDS_Win\NRDS_Win.vbs':
      source  => 'puppet:///modules/nagiosslave/NRDS_Win.vbs',
      mode    => '0777',
      require => File[ 'NRDS_directory' ],
      notify  => Exec [ 'run_nrdp' ],
    }

    file { 'C:\Program Files\Nagios\NRDS_Win\plugins':
      source  => 'puppet:///modules/nagiosslave/winplugins',
      mode    => '0777',
      recurse => true,
      require => File[ 'NRDS_directory' ],
      notify  => Exec [ 'run_nrdp' ],
    }

    file { 'C:\Program Files\Nagios\NRDS_Win\Host.ini':
      content => regsubst(template('nagiosslave/nrds.host.erb'), '\n', "\r\n", 'EMG'),
      require => File[ 'NRDS_directory' ],
      notify  => Exec [ 'run_nrdp' ],
    }

    file { 'C:/ProgramData/PuppetLabs/puppet/var/concat/C_':
      ensure => directory,
    } ->

    file { 'C:/ProgramData/PuppetLabs/puppet/var/concat/C_/Program Files':
      ensure => directory,
    } ->

    file { 'C:/ProgramData/PuppetLabs/puppet/var/concat/C_/Program Files/Nagios':
      ensure => directory,
    } ->

    file { 'C:/ProgramData/PuppetLabs/puppet/var/concat/C_/Program Files/Nagios/NRDS_Win':
      ensure => directory,
    } ->

    concat{ 'C:\Program Files\Nagios\NRDS_Win\config.ini':
      ensure  => present,
      owner   => 'Administrators',
      group   => 'Administrators',
      mode    => 0664,
      require => File[ 'NRDS_directory' ],
      notify  => Exec [ 'run_nrdp' ],
    }

    concat::fragment{"config_header":
      target  => 'C:\Program Files\Nagios\NRDS_Win\config.ini',
      content => template('nagiosslave/nrds.config_header.erb'),
      order   => 01,
    }

    concat::fragment{"config_default":
      target  => 'C:\Program Files\Nagios\NRDS_Win\config.ini',
      content => template('nagiosslave/nrds.confg.default.erb'),
      order   => 02,
    }

    # FIXME: we should be using the "scheduled_task" resource type for this.
    #
    # This bug prevents us from doing that at the moment:
    # https://projects.puppetlabs.com/issues/13008
    #
    #
    exec { 'make puppet scheduled task':
      command   => 'cmd.exe /C schtasks /Create /RU SYSTEM /SC MINUTE /MO 5 /TN \'Nagios_NRDP_client\' /TR \'C:\PROGRA~1\Nagios\NRDS_Win\NRDS_Win.vbs\'',
      path      => $::path,
      logoutput => true,
      onlyif    => 'cmd.exe /C schtasks /query /tn \'Nagios_NRDP_client\' & if errorlevel 1 (exit /b 0) else exit /b 1',
      require   => File[ 'C:\Program Files\Nagios\NRDS_Win\NRDS_Win.vbs' ],
    }

    exec { 'run_nrdp':
      command     => 'cmd.exe /C "C:\PROGRA~1\Nagios\NRDS_Win\NRDS_Win.vbs"',
      path        => $::path,
      refreshonly => true,
    }

  }

}
