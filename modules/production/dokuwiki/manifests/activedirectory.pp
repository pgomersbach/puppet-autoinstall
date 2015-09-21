class dokuwiki::activedirectory {
  package { 'php5-ldap':
    ensure => present,
    name   => 'php5-ldap',
  }

  file { '/etc/dokuwiki/acl.auth.php':
    mode   => '0644',
    owner  => root,
    group  => root,
    source => "puppet:///modules/${module_name}/acl.auth.php",
    notify => Exec['force-reload-apache2'],
  }
}
