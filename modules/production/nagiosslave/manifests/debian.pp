class nagiosslave::debian::fast {
  cron { 'runplugins-fast':
    command  => '/usr/local/bin/run_pluginsphp.sh /etc/run_plugins.conf /etc/nagiosslave.conf',
    user     => root,
  }
}


class nagiosslave::debian {

# pass variable to_monitor as "fqdn,osfamily,fqdn,osfamily" for monitoring. osfamily=linux,cisco, windows, etc


define gen_mon_config {
  $arrofservers=split($name,',')
  $server_to_mon = inline_template("<%= arrofservers[0] %>")
  $server_os = inline_template("<%= arrofservers[1] %>")
#  notify { "Found server $server_to_mon type $server_os":; }
  if $server_os == 'esxi41' {
    include nagiosslave::vsphere_sdk
  }

  if $server_os == 'esxi55' {
    include nagiosslave::vsphere_sdk
  }

  if $server_os == 'md3000' {
    include nagiosslave::md3000
  }

  if $server_os == 'store-vheeswijk' {
    include nagiosslave::esxidatastore
  }

  file { "/etc/nagios-plugins/plugins.d/${server_to_mon}.${server_os}.conf":
    mode    => '0655',
    owner   => root,
    group   => root,
    content => template("nagiosslave/${server_os}.erb"),
    require => File['/etc/nagios-plugins/plugins.d'],
    notify  => Exec['update-nagiosslave.conf'],
  }

#  @@nagios_host { $server_to_mon:
#    ensure        => present,
#    alias         => $server_to_mon,
#    address       => $server_to_mon,
#    check_command => 'check-host-alive',
#    use           => 'generic-host',
#    target        => "/etc/nagios3/resource.d/host_${::hostname}.cfg",
#    tag           => $domain,
#  }
}

# generate configuration for to_monitor - to_monitor20
$servers_to_monitor = split($to_monitor, ':')
gen_mon_config { $servers_to_monitor:; }
$servers_to_monitor1 = split($to_monitor1, ':')
gen_mon_config { $servers_to_monitor1:; }
$servers_to_monitor2 = split($to_monitor2, ':')
gen_mon_config { $servers_to_monitor2:; }
$servers_to_monitor3 = split($to_monitor3, ':')
gen_mon_config { $servers_to_monitor3:; }
$servers_to_monitor4 = split($to_monitor4, ':')
gen_mon_config { $servers_to_monitor4:; }
$servers_to_monitor5 = split($to_monitor5, ':')
gen_mon_config { $servers_to_monitor5:; }
$servers_to_monitor6 = split($to_monitor6, ':')
gen_mon_config { $servers_to_monitor6:; }
$servers_to_monitor7 = split($to_monitor7, ':')
gen_mon_config { $servers_to_monitor7:; }
$servers_to_monitor8 = split($to_monitor8, ':')
gen_mon_config { $servers_to_monitor8:; }
$servers_to_monitor9 = split($to_monitor9, ':')
gen_mon_config { $servers_to_monitor9:; }
$servers_to_monitor10 = split($to_monitor10, ':')
gen_mon_config { $servers_to_monitor10:; }
$servers_to_monitor11 = split($to_monitor11, ':')
gen_mon_config { $servers_to_monitor11:; }
$servers_to_monitor12 = split($to_monitor12, ':')
gen_mon_config { $servers_to_monitor12:; }
$servers_to_monitor13 = split($to_monitor13, ':')
gen_mon_config { $servers_to_monitor13:; }
$servers_to_monitor14 = split($to_monitor14, ':')
gen_mon_config { $servers_to_monitor14:; }
$servers_to_monitor15 = split($to_monitor15, ':')
gen_mon_config { $servers_to_monitor15:; }
$servers_to_monitor16 = split($to_monitor16, ':')
gen_mon_config { $servers_to_monitor16:; }
$servers_to_monitor17 = split($to_monitor17, ':')
gen_mon_config { $servers_to_monitor17:; }
$servers_to_monitor18 = split($to_monitor18, ':')
gen_mon_config { $servers_to_monitor18:; }
$servers_to_monitor19 = split($to_monitor19, ':')
gen_mon_config { $servers_to_monitor19:; }
$servers_to_monitor20 = split($to_monitor20, ':')
gen_mon_config { $servers_to_monitor20:; }



# collect exported resources
File <<| tag == "$domain.base.conf" |>>
File <<| tag == "$domain.splunk.conf" |>>

  package { [ 'curl', 'nagios-plugins', 'nagios-snmp-plugins', 'php5-cli', 'wget', 'snmp', 'psmisc', 'bc', 'php5-sybase', 'libipc-run-perl', 'freeipmi-tools' ]:
      ensure => 'present',
  }
  package { [ 'libwww-perl', 'libxml-simple-perl', 'libcrypt-ssleay-perl', 'libxml-parser-perl', 'liberror-perl', 'php-http', 'libstdc++6', 'build-essential' ]:
      ensure => 'present',
  }
  package { 'rubygems':
    ensure   => installed,
  }
  package { 'ruby-dev':
    ensure   => installed,
    require  => Package['rubygems'],
  }
  package { 'eventmachine':
    ensure   => installed,
    require  => Package['ruby-dev'],
    provider => 'gem',
  }
  package { 'amqp-utils':
    ensure   => installed,
    require  => Package['eventmachine'],
    provider => 'gem',
  }


$rnd = fqdn_rand(5)
$rnd5 = $rnd + 5
$rnd10 = $rnd + 10
$rnd15 = $rnd + 15
$rnd20 = $rnd + 20
$rnd25 = $rnd + 25
$rnd30 = $rnd + 30
$rnd35 = $rnd + 35
$rnd40 = $rnd + 40
$rnd45 = $rnd + 45
$rnd50 = $rnd + 50
$rnd55 = $rnd + 55
$rndrestart = fqdn_rand(30)

  cron { 'runplugins':
    command => '/usr/local/bin/run_pluginsphp.sh /etc/run_plugins.conf /etc/nagiosslave.conf',
    user    => root,
    minute  => [$rnd, $rnd5, $rnd10, $rnd15, $rnd20, $rnd25, $rnd30, $rnd35, $rnd40, $rnd45, $rnd50, $rnd55],
  }

  cron { 'restart-puppet':
    command => '/usr/sbin/service puppet stop;/usr/bin/killall puppet;sleep 3;rm -f /var/lib/puppet/state/agent_catalog_run.lock;/usr/sbin/service puppet start',
    user    => root,
    hour    => 4,
    minute  => $rndrestart,
  }

  cron { 'cleanup-procs':
    command => '/usr/bin/killall run_pluginsphp.sh',
    user    => root,
    hour    => 6,
    minute  => 4,
  }

  file { [ '/etc/nagios-plugins', '/etc/nagios-plugins/plugins.d' ]:
    ensure  => directory,
    recurse => true,
    purge   => true,
    force   => true,
    require => Package['nagios-plugins'],
    notify  => Exec['update-nagiosslave.conf'],
  }

  file { [ '/var/nagios_plugin_cache' ]:
    ensure  => directory,
    recurse => true,
    force   => true,
  }

  file { [ '/etc/nagios-plugins/config' ]:
    ensure  => directory,
    recurse => true,
    force   => true,
    require => Package['nagios-plugins'],
  }

  exec { 'update-nagiosslave.conf' :
    command     => '/bin/cat /etc/nagios-plugins/plugins.d/*.conf | /usr/bin/sort > /etc/nagiosslave.conf',
    refreshonly => true,
    notify      => Exec['run-nagiosslave'],
  }

  exec { 'run-nagiosslave' :
    command     => '/usr/local/bin/run_pluginsphp.sh /etc/run_plugins.conf /etc/nagiosslave.conf',
    timeout     => 600,
    refreshonly => true,
  }

  file { '/usr/local/bin/send_nrdp.sh':
    mode   => '0755',
    owner  => root,
    group  => root,
    source => 'puppet:///modules/nagiosslave/send_nrdp.sh',
    notify => Exec['update-nagiosslave.conf'],
  }

  file { '/usr/local/bin/send_nrdp.php':
    mode   => '0755',
    owner  => root,
    group  => root,
    source => 'puppet:///modules/nagiosslave/send_nrdp.php',
    notify => Exec['update-nagiosslave.conf'],
  }

  file { '/etc/run_plugins.conf':
    mode   => '0755',
    owner  => root,
    group  => root,
    source => 'puppet:///modules/nagiosslave/run_plugins.conf',
    notify => Exec['update-nagiosslave.conf'],
  }

  file { '/usr/local/bin/run_pluginsphp.sh':
    mode   => '0755',
    owner  => root,
    group  => root,
    source => 'puppet:///modules/nagiosslave/run_pluginsphp.sh',
    notify => Exec['update-nagiosslave.conf'],
  }

# Nagios plugins

  file { '/usr/lib/nagios/plugins/check_myslave.sh':
    mode    => '0755',
    owner   => root,
    group   => root,
    source  => 'puppet:///modules/nagiosslave/check_myslave.sh',
    require => File['/etc/nagios-plugins/plugins.d', '/var/nagios_plugin_cache'],
    notify  => Exec['update-nagiosslave.conf'],
  }

  file { '/usr/lib/nagios/plugins/check_md3000.pl':
    mode    => '0755',
    owner   => root,
    group   => root,
    source  => 'puppet:///modules/nagiosslave/check_md3000.pl',
    require => File['/etc/nagios-plugins/plugins.d', '/var/nagios_plugin_cache'],
    notify  => Exec['update-nagiosslave.conf'],
  }

  file { '/usr/lib/nagios/plugins/stats_md3000.pl':
    mode    => '0755',
    owner   => root,
    group   => root,
    source  => 'puppet:///modules/nagiosslave/stats_md3000.pl',
    require => File['/etc/nagios-plugins/plugins.d', '/var/nagios_plugin_cache'],
    notify  => Exec['update-nagiosslave.conf'],
  }

  file { '/usr/lib/nagios/plugins/check_ups_apc.pl':
    mode    => '0755',
    owner   => root,
    group   => root,
    source  => 'puppet:///modules/nagiosslave/check_ups_apc.pl',
    require => File['/etc/nagios-plugins/plugins.d', '/var/nagios_plugin_cache'],
    notify  => Exec['update-nagiosslave.conf'],
  }

  file { '/usr/lib/nagios/plugins/check_snmp_cisco_wlc.pl':
    mode    => '0755',
    owner   => root,
    group   => root,
    source  => 'puppet:///modules/nagiosslave/check_snmp_cisco_wlc.pl',
    require => File['/etc/nagios-plugins/plugins.d', '/var/nagios_plugin_cache'],
    notify  => Exec['update-nagiosslave.conf'],
  }

  file { '/usr/lib/nagios/plugins/check_equallogic.sh':
    mode    => '0755',
    owner   => root,
    group   => root,
    source  => 'puppet:///modules/nagiosslave/check_equallogic.sh',
    require => File['/etc/nagios-plugins/plugins.d'],
    notify  => Exec['update-nagiosslave.conf'],
  }

  file { '/usr/lib/nagios/plugins/check_files_count_http.sh':
    mode    => '0755',
    owner   => root,
    group   => root,
    source  => 'puppet:///modules/nagiosslave/check_files_count_http.sh',
    require => File['/etc/nagios-plugins/plugins.d'],
    notify  => Exec['update-nagiosslave.conf'],
  }

  file { '/usr/lib/nagios/plugins/check_cisco_firewall.sh':
    mode    => '0755',
    owner   => root,
    group   => root,
    source  => 'puppet:///modules/nagiosslave/check_cisco_firewall.sh',
    require => File['/etc/nagios-plugins/plugins.d'],
    notify  => Exec['update-nagiosslave.conf'],
  }

  file { '/usr/lib/nagios/plugins/submit_service_check.sh':
    mode    => '0755',
    owner   => root,
    group   => root,
    source  => 'puppet:///modules/nagiosslave/submit_service_check.sh',
    require => File['/etc/nagios-plugins/plugins.d'],
    notify  => Exec['update-nagiosslave.conf'],
  }

  file { '/usr/lib/nagios/plugins/check_x224':
    mode    => '0755',
    owner   => root,
    group   => root,
    source  => 'puppet:///modules/nagiosslave/check_x224',
    require => File['/etc/nagios-plugins/plugins.d'],
    notify  => Exec['update-nagiosslave.conf'],
  }

  file { '/usr/lib/nagios/plugins/check_hp_bladechassis':
    mode    => '0755',
    owner   => root,
    group   => root,
    source  => 'puppet:///modules/nagiosslave/check_hp_bladechassis',
    require => File['/etc/nagios-plugins/plugins.d'],
    notify  => Exec['update-nagiosslave.conf'],
  }

  file { '/usr/lib/nagios/plugins/check_logfiles':
    mode    => '0755',
    owner   => root,
    group   => root,
    source  => 'puppet:///modules/nagiosslave/check_logfiles',
    require => File['/etc/nagios-plugins/plugins.d'],
    notify  => Exec['update-nagiosslave.conf'],
  }

  file { '/usr/lib/nagios/plugins/check_mssql':
    mode    => '0755',
    owner   => root,
    group   => root,
    source  => 'puppet:///modules/nagiosslave/check_mssql',
    require => File['/etc/nagios-plugins/plugins.d'],
    notify  => Exec['update-nagiosslave.conf'],
  }

  file { '/usr/lib/nagios/plugins/check_ipmi_sensor':
    mode    => '0755',
    owner   => root,
    group   => root,
    source  => 'puppet:///modules/nagiosslave/check_ipmi_sensor',
    require => File['/etc/nagios-plugins/plugins.d'],
    notify  => Exec['update-nagiosslave.conf'],
  }

  file { '/usr/lib/nagios/plugins/check_nagios_nrservice.sh':
    mode    => '0755',
    owner   => root,
    group   => root,
    source  => 'puppet:///modules/nagiosslave/check_nagios_nrservice.sh',
    require => File['/etc/nagios-plugins/plugins.d'],
    notify  => Exec['update-nagiosslave.conf'],
  }

  file { '/usr/lib/nagios/plugins/check_nagios_nrhosts.sh':
    mode    => '0755',
    owner   => root,
    group   => root,
    source  => 'puppet:///modules/nagiosslave/check_nagios_nrhosts.sh',
    require => File['/etc/nagios-plugins/plugins.d'],
    notify  => Exec['update-nagiosslave.conf'],
  }

  file { '/usr/lib/nagios/plugins/check_qnap_download.sh':
    mode    => '0755',
    owner   => root,
    group   => root,
    source  => 'puppet:///modules/nagiosslave/check_qnap_download.sh',
    require => File['/etc/nagios-plugins/plugins.d'],
    notify  => Exec['update-nagiosslave.conf'],
  }

  file { '/usr/lib/nagios/plugins/check_snmp_printer':
    mode    => '0755',
    owner   => root,
    group   => root,
    source  => 'puppet:///modules/nagiosslave/check_snmp_printer',
    require => File['/etc/nagios-plugins/plugins.d'],
    notify  => Exec['update-nagiosslave.conf'],
  }

  file { '/usr/lib/nagios/plugins/check_outsideip.sh':
    mode    => '0755',
    owner   => root,
    group   => root,
    source  => 'puppet:///modules/nagiosslave/check_outsideip.sh',
    require => File['/etc/nagios-plugins/plugins.d'],
    notify  => Exec['update-nagiosslave.conf'],
  }

  file { '/usr/lib/nagios/plugins/check_cisco_ips.pl':
    mode    => '0755',
    owner   => root,
    group   => root,
    source  => 'puppet:///modules/nagiosslave/check_cisco_ips.pl',
    require => File['/etc/nagios-plugins/plugins.d'],
    notify  => Exec['update-nagiosslave.conf'],
    replace => false,
  }

  file { '/usr/lib/nagios/plugins/check_vmware.pl':
    mode    => '0755',
    owner   => root,
    group   => root,
    source  => 'puppet:///modules/nagiosslave/check_vmware.pl',
    require => File['/etc/nagios-plugins/plugins.d'],
    notify  => Exec['update-nagiosslave.conf'],
  }

  file { '/usr/lib/nagios/plugins/check_webinject':
    mode    => '0755',
    owner   => root,
    group   => root,
    source  => 'puppet:///modules/nagiosslave/check_webinject',
    require => File['/etc/nagios-plugins/plugins.d'],
    notify  => Exec['update-nagiosslave.conf'],
  }

  if file_exists("/etc/puppet/modules/production/nagiosslave/files/checks/${fqdn}.conf") == 1 {
    file { "/etc/nagios-plugins/plugins.d/${fqdn}.conf":
      mode    => '0655',
      owner   => root,
      group   => root,
      source  => [ "puppet:///modules/nagiosslave/checks/${fqdn}.conf" ],
      require => File['/etc/nagios-plugins/plugins.d'],
      notify  => Exec['update-nagiosslave.conf'],
    }
  }

  file { '/etc/nagios-plugins/plugins.d/default.conf':
    mode    => '0655',
    owner   => root,
    group   => root,
    content => template('nagiosslave/slave.erb'),
    require => File['/etc/nagios-plugins/plugins.d'],
    notify  => Exec['update-nagiosslave.conf'],
  }

}
