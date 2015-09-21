class nagiosslave::md3000 {

  remote_file{'/tmp/smclient-dell_10.75.G6.12-2_all.deb':
    remote_location => 'https://s3-eu-west-1.amazonaws.com/puppet-autoinstall/files/smclient-dell_10.75.G6.12-2_all.deb'
  }

  package { "smclient-dell":
    source   => "/tmp/smclient-dell_10.75.G6.12-2_all.deb",
    require  => Remote_file[ '/tmp/smclient-dell_10.75.G6.12-2_all.deb' ],
  }

}
