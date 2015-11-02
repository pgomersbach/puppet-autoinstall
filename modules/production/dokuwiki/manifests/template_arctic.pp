class dokuwiki::template_arctic {
  file {'dokuwiki_template_arctic':
    path    => '/tmp/arctic-stable.tgz',
    source  => "puppet:///modules/${module_name}/arctic-stable.tgz",
    require => Exec[ 'install_docuwiki' ],
  }

  exec {'install_template_arctic':
    command => '/bin/tar zxf /tmp/arctic-stable.tgz -C /var/lib/dokuwiki/lib/tpl',
    creates => '/var/lib/dokuwiki/lib/tpl/arctic',
    require => File['dokuwiki_template_arctic'],
  }
}
