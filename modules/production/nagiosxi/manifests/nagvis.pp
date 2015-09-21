class nagiosxi::nagvis {
  exec { "download-nagvis":
    cwd => "/tmp",
    command => "/usr/bin/wget http://assets.nagios.com/downloads/nagiosxi/scripts/NagiosXI-Nagvis.sh",
    creates => "/tmp/NagiosXI-Nagvis.sh",
  }

  exec { "install-nagvis":
    cwd => "/tmp",
    command => "/bin/sh /tmp/NagiosXI-Nagvis.sh",
    timeout => 1800,
    logoutput => on_failure,
    creates => "/usr/local/nagvis",
    require => [ Exec["download-nagvis"] ],
  }

}
