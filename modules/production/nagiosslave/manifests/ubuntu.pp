class nagiosslave::ubuntu {
  exec { 'patch-plugins':
    cwd         => '/usr/lib/nagios/plugins',
    command     => "/bin/sed -i 's/Net::SNMP->VERSION < 4/Net::SNMP->VERSION lt 4/g' *.pl",
    onlyif      => "/bin/grep 'Net::SNMP->VERSION < 4' *.pl",
  }
}
