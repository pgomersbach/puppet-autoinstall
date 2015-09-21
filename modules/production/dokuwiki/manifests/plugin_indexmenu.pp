class dokuwiki::plugin_indexmenu {
  file {'dokuwiki_plugin_indexmenu':
    path    => '/tmp/indexmenu.zip',
    source  => "puppet:///modules/${module_name}/indexmenu.zip",
    require => Exec[ 'install_docuwiki' ],
  }

  exec {'install_plugin_indexmenu':
    command => '/usr/bin/unzip /tmp/indexmenu.zip -d /var/lib/dokuwiki/lib/plugins',
    creates => '/var/lib/dokuwiki/lib/plugins/indexmenu',
    require => File['dokuwiki_plugin_indexmenu'],
  }
}
