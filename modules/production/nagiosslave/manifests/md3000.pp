class nagiosslave::md3000 {
  file {'smclient':
    path    => '/tmp/smclient-dell_10.75.G6.12-2_all.deb',
    source  => "puppet:///modules/${module_name}/smclient-dell_10.75.G6.12-2_all.deb",
  }

  package { "smclient-dell":
    provider => dpkg,
    source   => "/tmp/smclient-dell_10.75.G6.12-2_all.deb",
    require  => File[ 'smclient' ],
  }

}
