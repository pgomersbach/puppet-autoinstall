class splunk::linux_forwarder {

  file {"unixappta_installer":
    path    => "${splunk::params::linux_stage_dir}/Splunk_TA_nix.tar.gz",
    source  => "puppet:///modules/${module_name}/Splunk_TA_nix.tar.gz",
    require => Package["splunkforwarder"],
  }
  exec {"install_unixappta":
    command => "/opt/splunkforwarder/bin/splunk install app ${splunk::params::linux_stage_dir}/Splunk_TA_nix.tar.gz -auth $splunk_admin:$splunk_admin_pass",
    creates => "/opt/splunkforwarder/etc/apps/Splunk_TA_nix/default/app.conf",
    require => File["unixappta_installer"],
    notify  => Service["splunk"],
  }
  exec {"enable_unixappta":
    command => "/opt/splunkforwarder/bin/splunk enable app Splunk_TA_nix",
    unless  => "/bin/grep 'state = enabled' /opt/splunkforwarder/etc/apps/Splunk_TA_nix/local/app.conf",
    require => Exec["install_unixappta"],
    notify  => Service["splunk"],
  }
  file {"unixappta_inputs":
    path    => "/opt/splunkforwarder/etc/apps/Splunk_TA_nix/local/inputs.conf",
    source  => "puppet:///modules/${module_name}/unix.inputs.conf",
    require => Exec["enable_unixappta"],
    notify  => Service["splunk"],
  }
  package { [ 'sysstat', 'lsof', 'auditd', 'ntpdate']:
    ensure => 'present',
  }

  file {"${splunk::params::linux_stage_dir}":
    ensure => directory,
    owner  => "root",
    group  => "root",
  }
  file {"splunk_installer":
    path    => "${splunk::params::linux_stage_dir}/${splunk::params::installer}",
    source  => "puppet:///modules/${module_name}/${splunk::params::installer}",
    require => File["${splunk::params::linux_stage_dir}"],
  }
  package {"splunkforwarder":
    ensure   => installed,
    source   => "${splunk::params::linux_stage_dir}/${splunk::params::installer}",
    provider => $::operatingsystem ? {
      /(?i)(centos|redhat)/   => 'rpm',
      /(?i)(debian|ubuntu)/ => 'dpkg',
    },
    notify   => Exec['start_splunk'],
  }
  firewall { "100 allow Splunkd":
    action => "accept",
    proto  => "tcp",
    dport  => "${splunk::params::splunkd_port}",
  }
  exec {"start_splunk":
    creates => "/opt/splunkforwarder/etc/licenses",
    command => "/opt/splunkforwarder/bin/splunk start --accept-license",
    timeout => 0,
  }
  exec {"set_forwarder_port":
    unless  => "/bin/grep \"server \= ${splunk::params::logging_server}:${splunk::params::logging_port}\" /opt/splunkforwarder/etc/system/local/outputs.conf",
    command => "/opt/splunkforwarder/bin/splunk add forward-server ${splunk::params::logging_server}:${splunk::params::logging_port} -auth ${splunk::params::splunk_admin}:${splunk::params::splunk_admin_pass}",
    require => Exec['set_monitor_default'],
    notify  => Service['splunk'],
  }
  exec {"set_monitor_default":
    unless  => "/bin/grep \"\/var\/log\" /opt/splunkforwarder/etc/apps/search/local/inputs.conf",
    command => "/opt/splunkforwarder/bin/splunk add monitor \"/var/log/\" -auth ${splunk::params::splunk_admin}:${splunk::params::splunk_admin_pass}",
    require => Exec['start_splunk','set_boot'],
  }
  exec {"set_boot":
    creates => "/etc/init.d/splunk",
    command => "/opt/splunkforwarder/bin/splunk enable boot-start",
    require => Exec['start_splunk'],
  }
  file {'/etc/init.d/splunk':
    ensure  => file,
    require => Exec['set_boot']
  }
  service {"splunk":
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    require    => File['/etc/init.d/splunk'],
  }
}
