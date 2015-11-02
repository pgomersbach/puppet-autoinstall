class syslog_agent {

## DEFAULTS FOR VARIABLES USERS CAN SET
# (Here are set the defaults, provide your custom variables externally)
# (The default used is in the line with '')

  $server = $syslog_server ? {
    ''      => '127.0.0.1',
    default => "${syslog_server}",
  }

#  notify{"The syslogserver is: ${server}": }
#  notify{"The systype is: ${osfamily}": }

  if $osfamily == 'Debian' {

    package { 'rsyslog':
      ensure => present,
    }

    service { 'rsyslog':
      ensure     => running,
      enable     => true,
      hasrestart => true,
      require    => Package['rsyslog'],
      subscribe  => File['/etc/rsyslog.conf'],
    }

    file { '/etc/rsyslog.conf':
      content => template('syslog_agent/rsyslog.conf.erb'),
    }
  }

  if $osfamily == 'windows' {
    if $architecture == 'x64' {

      file { 'c:/Windows/SyslogAgent.exe':
        owner  => 'Administrators',
        group  => 'Administrators',
        mode   => '0777',
        source => 'puppet:///modules/syslog_agent/x64/SyslogAgent.exe',
      }

      file { 'c:/Windows/SyslogAgentConfig.exe':
        owner  => 'Administrators',
        group  => 'Administrators',
        mode   => '0777',
        source => 'puppet:///modules/syslog_agent/x64/SyslogAgentConfig.exe',
      }

  } else {

    file { 'c:/Windows/SyslogAgent.exe':
      owner  => 'Administrators',
      group  => 'Administrators',
      mode   => '0777',
      source => 'puppet:///modules/syslog_agent/x32/SyslogAgent.exe',
    }

    file { 'c:/Windows/SyslogAgentConfig.exe':
      owner  => 'Administrators',
      group  => 'Administrators',
      mode   => '0777',
      source => 'puppet:///modules/syslog_agent/x32/SyslogAgentConfig.exe',
    }
  }

  file { 'c:/Windows/isrunning.bat':
    owner  => 'Administrators',
    group  => 'Administrators',
    mode   => '0777',
    source => 'puppet:///modules/syslog_agent/isrunning.bat',
  }

  exec { 'SyslogAgent.exe':
    command   => "c:/Windows/SyslogAgent.exe -install ${server}",
    provider  => windows,
    subscribe => File['c:/Windows/SyslogAgent.exe'],
    unless    => 'c:\Windows\isrunning.bat SyslogAgent.exe',
  }

  service { 'Syslog Agent':
    ensure  => 'running',
    enable  => true,
    require => Exec['SyslogAgent.exe'],
  }
}
}
