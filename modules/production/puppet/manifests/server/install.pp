class puppet::server::install {
  package { 'puppetmaster': ensure => installed }
}
