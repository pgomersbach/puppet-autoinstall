class dokuwiki {
  $wikipackages = [ 'dokuwiki', 'libjs-jquery', 'libjs-jquery-ui', 'javascript-common', 'wwwconfig-common', ]
  package { $wikipackages: ensure => present }

  include dokuwiki::plugin_fckg_lite
  include dokuwiki::plugin_indexmenu
  include dokuwiki::template_arctic
  include dokuwiki::puppetdoc

  if $::ad_servers {
    include dokuwiki::activedirectory
  }

  file {'cookie_deb':
    path    => '/tmp/libjs-jquery-cookie_4-1~bpo60+1_all.deb',
    source  => "puppet:///modules/${module_name}/libjs-jquery-cookie_4-1~bpo60+1_all.deb",
    require => Package[ $wikipackages ],
  }

  exec {'install_cookie':
    command => '/usr/bin/dpkg -i --force-all /tmp/libjs-jquery-cookie_4-1~bpo60+1_all.deb',
    creates => '/usr/share/javascript/jquery-cookie/jquery.cookie.js',
    require => File['cookie_deb'],
  }

  file {'dokuwiki_deb':
    path    => '/tmp/dokuwiki_0.0.20120125b-2_all.deb',
    source  => "puppet:///modules/${module_name}/dokuwiki_0.0.20120125b-2_all.deb",
    require => Exec[ 'install_cookie' ],
  }

  exec {'install_docuwiki':
    command => '/usr/bin/dpkg -i --force-all /tmp/dokuwiki_0.0.20120125b-2_all.deb',
    creates => '/var/lib/dokuwiki',
    require => File['dokuwiki_deb'],
  }

  file { '/etc/dokuwiki/apache.conf':
    mode   => '0644',
    owner  => root,
    group  => root,
    source => 'puppet:///modules/dokuwiki/apache.conf',
    notify => Exec['force-reload-apache2'],
  }

  file { '/etc/dokuwiki/local.php':
    mode    => '0644',
    owner   => root,
    group   => root,
    content => template('dokuwiki/local.erb'),
    notify  => Exec['force-reload-apache2'],
  }

  exec { 'force-reload-apache2':
    command     => '/etc/init.d/apache2 force-reload',
    refreshonly => true,
  }
}
