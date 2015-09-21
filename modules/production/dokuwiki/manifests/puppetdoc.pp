# Clone puppet git repo and generate documentation for use in dokuwiki

class dokuwiki::puppetdoc {
  exec {'get_puppetdoc':
    command => '/usr/bin/git clone https://code.google.com/p/puppet-autoinstall/ /src/puppet-autoinstall',
    creates => '/src/puppet-autoinstall',
  }

  exec {'generate_puppetdoc':
    command => '/usr/bin/puppet doc --mode rdoc --all --modulepath /src/puppet-autoinstall/modules/production/ --outputdir /var/www/puppet-autoinstall',
    creates => '/var/www/puppet-autoinstall/index.html',
    require => Exec['get_puppetdoc'],
  }

  file { '/src/puppet-autoinstall/.git/FETCH_HEAD':
    audit => content,
  }

  exec { '/bin/rm -rf /var/www/puppet-autoinstall; /usr/bin/puppet doc --mode rdoc --all --modulepath /src/puppet-autoinstall/modules/production/ --outputdir /var/www/puppet-autoinstall':
    subscribe    => File['/src/puppet-autoinstall/.git/FETCH_HEAD'],
    refreshonly  => true,
  }

  cron { 'update_git':
    command         => 'cd /src/puppet-autoinstall; /usr/bin/git pull',
    user            => root,
    hour            => 5,
    minute          => 4,
  }
}
