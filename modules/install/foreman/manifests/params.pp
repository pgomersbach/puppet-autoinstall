class foreman::params {

# Basic configurations
#  $foreman_url  = "http://${::fqdn}"
#  $foreman_url  = "http://puppet.rely.nl:3000"
$foreman_url  = "http://localhost:3000"
  # Should foreman act as an external node classifier (manage puppet class assignments)
  $enc          = true
  # Should foreman receive reports from puppet
  $reports      = true
  # Should foreman recive facts from puppet
  $facts        = true
  # Do you use storeconfig (and run foreman on the same database) ? (note: not required)
  $storeconfigs = true
  # should foreman manage host provisioning as well
  $unattended   = no
  # Enable users authentication (default user:admin pw:changeme)
  $authentication = true
  # configure foreman via apache and passenger
  $passenger    = true
  # force SSL (note: requires passenger)
  $ssl          = false

# Advance configurations - no need to change anything here by default
  # allow usage of test / RC rpms as well
  $use_testing = true
  $railspath   = '/usr/share'
  $app_root    = "${railspath}/foreman"
  $user        = 'foreman'
  $environment = 'production'

  # OS specific paths
  case $::operatingsystem {
    redhat,centos,fedora,Scientific: {
      $puppet_basedir  = '/usr/lib/ruby/site_ruby/1.8/puppet'
      $apache_conf_dir = '/etc/httpd/conf.d'
    }
    Debian,Ubuntu: {
      $puppet_basedir  = '/usr/lib/ruby/1.8/puppet'
      $apache_conf_dir = '/etc/apache2/conf.d'
    }
    default:              {
      $puppet_basedir  = '/usr/lib/ruby/1.8/puppet'
      $apache_conf_dir = '/etc/apache2/conf.d/foreman.conf'
    }
  }
  $puppet_home = '/var/lib/puppet'
}
