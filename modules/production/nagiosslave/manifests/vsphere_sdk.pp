class nagiosslave::vsphere_sdk {
  if $::architecture == 'i386' {
    remote_file{'/tmp/VMware-vSphere-Perl-SDK-4.1.0-254719.tar.gz':
      remote_location => 'https://s3-eu-west-1.amazonaws.com/puppet-autoinstall/files/VMware-vSphere-Perl-SDK-4.1.0-254719.tar.gz'
      notify => Exec['unpacksdk'],
    }

#    file { '/tmp/VMware-vSphere-Perl-SDK-4.1.0-254719.tar.gz':
#      owner  => 'root',
#      group  => 'root',
#      mode   => '0655',
#      source => 'puppet:///modules/nagiosslave/VMware-vSphere-Perl-SDK-4.1.0-254719.i386.tar.gz',
#      notify => Exec['unpacksdk'],
#    }

    package { [ 'gcc', 'uuid', 'uuid-dev', 'libssl-dev', 'perl-doc', 'liburi-perl', 'libxml-libxml-perl' ]:
      ensure => 'present',
    }

  } else {
    remote_file{'/tmp/VMware-vSphere-Perl-SDK-4.1.0-254719.tar.gz':
      remote_location => 'https://s3-eu-west-1.amazonaws.com/puppet-autoinstall/files/VMware-vSphere-Perl-SDK-4.1.0-254719.x86_64.tar.gz'
      notify => Exec['unpacksdk'],
    }

#    file { '/tmp/VMware-vSphere-Perl-SDK-4.1.0-254719.tar.gz':
#      owner  => 'root',
#      group  => 'root',
#      mode   => '0655',
#      source => 'puppet:///modules/nagiosslave/VMware-vSphere-Perl-SDK-4.1.0-254719.x86_64.tar.gz',
#      notify => Exec['unpacksdk'],
#    }

    package { [ 'ia32-libs', 'build-essential', 'gcc', 'uuid', 'uuid-dev', 'perl', 'libssl-dev', 'perl-doc', 'liburi-perl', 'libxml-libxml-pe
rl', 'libcrypt-ssleay-perl' ]:
      ensure => 'present',
    }
  }

  exec { 'unpacksdk' :
    command     => '/bin/tar zxf /tmp/VMware-vSphere-Perl-SDK-4.1.0-254719.tar.gz',
    cwd         => '/tmp',
    refreshonly => true,
    notify      => File['/tmp/vmware-vsphere-cli-distrib/vmware-install.pl'],
  }

  file { '/tmp/vmware-vsphere-cli-distrib/vmware-install.pl':
    owner  => 'root',
    group  => 'root',
    mode   => '0555',
    source => 'puppet:///modules/nagiosslave/vmware-install.pl',
    notify => Exec['installsdk'],
  }

  exec { 'installsdk' :
    command => '/tmp/vmware-vsphere-cli-distrib/vmware-install.pl --default EULA_AGREED=yes',
    cwd     => '/tmp/vmware-vsphere-cli-distrib',
    creates => '/usr/bin/vicfg-ntp',
  }
}

