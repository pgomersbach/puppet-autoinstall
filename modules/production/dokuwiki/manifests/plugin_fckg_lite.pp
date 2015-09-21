class dokuwiki::plugin_fckg_lite {
  file {'dokuwiki_plugin_fckg_lite':
    path    => '/tmp/fckg_lite.tgz',
    source  => "puppet:///modules/${module_name}/fckg_lite.tgz",
    require => Exec[ 'install_docuwiki' ],
  }

  exec {'install_plugin_fckg_lite':
    command => '/bin/tar zxf /tmp/fckg_lite.tgz -C /var/lib/dokuwiki/lib/plugins',
    creates => '/var/lib/dokuwiki/lib/plugins/fckg',
    require => File['dokuwiki_plugin_fckg_lite'],
  }

  file {'chkacl_plugin_fckg_lite':
    path    => '/var/lib/dokuwiki/lib/plugins/fckg/fckeditor/editor/filemanager/connectors/php/check_acl.php',
    source  => "puppet:///modules/${module_name}/fckg_check_acl.php",
    require => Exec['install_plugin_fckg_lite'],
  }
}
