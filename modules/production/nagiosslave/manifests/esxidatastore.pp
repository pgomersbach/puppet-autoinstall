class nagiosslave::esxidatastore {

  file { [ '/usr/local/nagios/', '/usr/local/nagios/var/', '/usr/local/nagios/libexec/' ]:
    ensure => directory,
    owner  => root,
    group  => root,
  }

  file { '/usr/local/nagios/var/check_vmfs.err':
    ensure  => present,
    owner   => root,
    group   => root,
    require => File['/usr/local/nagios/', '/usr/local/nagios/var/', '/usr/local/nagios/libexec/'],
  }

  file { '/usr/lib/nagios/plugins/check_vmfs.sh':
    mode    => '0755',
    owner   => root,
    group   => root,
    source  => "puppet:///modules/${module_name}/check_vmfs.sh",
    require => File['/etc/nagios-plugins/plugins.d', '/var/nagios_plugin_cache'],
    notify  => Exec['update-nagiosslave.conf'],
  }


}
