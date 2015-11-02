class nagiosxi::install {
  exec { "download-nagiosxi":
    cwd => "/tmp",
    command => "/usr/bin/wget http://assets.nagios.com/downloads/nagiosxi/xi-latest.tar.gz",
    creates => "/tmp/xi-latest.tar.gz",
  }

  exec { "unpack-nagiosxi":
    cwd => "/tmp",
    command => "/bin/tar xzf /tmp/xi-latest.tar.gz",
    creates => "/tmp/nagiosxi",
    require => [ Exec["download-nagiosxi"] ],
  }

  exec { "install-nagiosxi":
    cwd       => "/tmp/nagiosxi",
    command   => "/tmp/nagiosxi/fullinstall -n",
    timeout   => 1800,
    logoutput => on_failure,
    creates   => "/usr/local/nagiosxi",
    require   => [ Exec["unpack-nagiosxi"] ],
  }

  file { "/usr/local/nagios/libexec/handle_TD_incident":
    mode    => "755",
    owner   => root,
    group   => root,
    source  => "puppet:///modules/${module_name}/handle_TD_incident.1.6.8-rely-0.2",
    require => [ Package[ 'perl-TimeDate', 'perl-Date-Calc' ] ],
  }

  package { [ 'perl-TimeDate', 'perl-Date-Calc', 'php-ldap', 'gcc', 'gcc-c++' ]:
    ensure => 'present',
  }

  package { 'rubygems':
    ensure   => installed,
  }
  package { 'ruby-devel':
    ensure   => installed,
    require  => Package['rubygems'],
  }
  package { 'amqp-utils':
    ensure   => installed,
    require  => Package['ruby-devel'],
    provider => 'gem',
  }
}
