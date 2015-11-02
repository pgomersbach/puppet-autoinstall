class puppet::config {
  file { $puppet::params::dir:
    ensure => directory,
  }

  file { "${puppet::params::dir}/puppet.conf":
    content => template('puppet/puppet.conf.erb'),
    notify => Exec["restart-puppet"],
  }

  exec { "restart-puppet" :
    command         =>      "/etc/init.d/puppet restart",
    refreshonly     =>      true,
  }


}
