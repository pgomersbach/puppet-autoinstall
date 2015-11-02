class shellshock {

  if $lsbdistcodename == 'squeeze' {
    include apt

    file { '/etc/apt/sources.list.d/lts.list':
      source => 'puppet:///modules/shellshock/lts.list',
      notify => Exec['apt_update'],
    }

    apt::key { 'lts':
      ensure => 'present',
      id     => '8B48AD6246925553',
      notify => Exec['apt_update'],
    }

  }

  if $kernel == 'Linux' {
    package { 'bash':
      ensure => latest,
    }
  }
}
