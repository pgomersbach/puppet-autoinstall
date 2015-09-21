class splunk::windows_forwarder {
  file {"${splunk::params::windows_stage_drive}\\installers":
    ensure => directory;
  }
  file {"splunk_installer":
    path   => "${splunk::params::windows_stage_drive}\\installers\\${installer}",
    source => "puppet:///modules/${module_name}/${splunk::params::installer}",
  }
  package {"Universal Forwarder":
    source          => "${splunk::params::windows_stage_drive}\\installers\\${installer}",
    install_options => {
      "AGREETOLICENSE"         => 'Yes',
      "RECEIVING_INDEXER"      => "${splunk::params::logging_server}:${splunk::params::logging_port}",
      "LAUNCHSPLUNK"           => "1",
      "SERVICESTARTTYPE"       => "auto",
      "WINEVENTLOG_APP_ENABLE" => "1",
      "WINEVENTLOG_SEC_ENABLE" => "1",
      "WINEVENTLOG_SYS_ENABLE" => "1",
      "WINEVENTLOG_FWD_ENABLE" => "1",
      "WINEVENTLOG_SET_ENABLE" => "1",
      "ENABLEADMON"            => "1",
    },
    require         => File['splunk_installer'],
  }
  service {"SplunkForwarder":
    ensure  => running,
    enable  => true,
    require => Package['Universal Forwarder'],
  }


# export config for windows app on splunk indexer
  @@file {"windowsapp_installer":
    tag     => "$domain.splunk.apps.installer",
    path    => "${splunk::params::linux_stage_dir}/windows.tar.gz",
    source  => "puppet:///modules/${module_name}/windows.tar.gz",
    require => File["${splunk::params::linux_stage_dir}"],
  }
  @@exec {"install_windowsapp":
    tag     => "$domain.splunk.apps.install",
    command => "/opt/splunk/bin/splunk install app ${splunk::params::linux_stage_dir}/windows.tar.gz -update true",
    creates => "/opt/splunk/etc/apps/windows/default/app.conf",
    require => File["windowsapp_installer"],
    notify  => Service["splunkd"],
  }
  @@exec {"enable_windowsapp":
    tag     => "$domain.splunk.apps.install",
    command => "/opt/splunk/bin/splunk enable app windows",
    unless  => "/bin/grep 'state = enabled' /opt/splunk/etc/apps/windows/local/app.conf",
    require => Exec["install_windowsapp"],
    notify  => Service["splunkd"],
  }
  @@file {"windowsapp_inputs":
    tag     => "$domain.splunk.apps.installer",
    path    => "/opt/splunk/etc/apps/windows/local/inputs.conf",
    source  => "puppet:///modules/${module_name}/windows.inputs.conf",
    require => Exec["enable_windowsapp"],
    notify  => Service["splunkd"],
  }

}
