# == Class: update
#
# Full description of class update here.
#
# === Parameters
#
# Document parameters here.
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
# === Variables
#
# Here you should define a list of variables that this module would require.
#
# [*sample_variable*]
#   Explanation of how this variable affects the funtion of this class and if it
#   has a default. e.g. "The parameter enc_ntp_servers must be set by the
#   External Node Classifier as a comma separated list of hostnames." (Note,
#   global variables should not be used in preference to class parameters  as of
#   Puppet 2.6.)
#
# === Examples
#
#  class { update:
#    servers => [ 'pool.ntp.org', 'ntp.local.company.com' ]
#  }
#
# === Authors
#
# Author Name <author@domain.com>
#
# === Copyright
#
# Copyright 2011 Your name here, unless otherwise noted.
#
class update(
  $newpuppetmaster = 'foreman.rely.nl',
  $newpuppetip     = '54.75.227.63',
) {
#  file { "/etc/apt/sources.list":
#    source => "puppet:///modules/update/sources.list.${lsbdistcodename}",
#    ensure => present;
#  }
  case $::osfamily {
    'Debian': {
#      exec { '/usr/bin/apt-get clean': }
#      exec { '/usr/bin/apt-get update': }
       host { $newpuppetmaster:
         ip => $newpuppetip,
      }
      augeas {'puppet.conf.migrate':
        context => '/files/etc/puppet/puppet.conf/agent',
        changes => ["set server ${update::newpuppetmaster}",
        ]
      }
 
  # These next two objects handle migration to a new puppet master
  # server - if the value of $newpuppetmaster is updated, the
  # puppet-clear-certs.sh script is executed.
      file {'/var/lib/puppet/lib/puppet-clear-certs.sh':
        owner  => 'root',
        group  => 'root',
        mode   => 700,
        source => 'puppet:///modules/update/puppet-clear-certs.sh',
      }
 
      exec {'/var/lib/puppet/lib/puppet-clear-certs.sh':
        path    => ['/usr/bin', '/bin', '/usr/sbin', '/sbin'],
        require => [File ['/var/lib/puppet/lib/puppet-clear-certs.sh'],
                Augeas ['puppet.conf.migrate'],
                ],
        unless  => ["openssl x509 -text -in /var/lib/puppet/ssl/certs/ca.pem | grep ${update::newpuppetmaster} >/dev/null 2>&1",
                "openssl x509 -text -in /var/lib/puppet/ssl/certs/${fqdn}.pem | grep ${update::newpuppetmaster} >/dev/null 2>&1",
                ]
      }
    }
    'RedHat': {
      notify{"Update not needed for ${::osfamily} operatingsystem: ${::operatingsystem}": }
    }
    default: {
      notify{"Update not possiblefor ${::osfamily} operatingsystem: ${::operatingsystem}": }
    }
  }


#  exec { "/usr/bin/wget -q -O - http://apt.puppetlabs.com/pubkey.gpg | /usr/bin/apt-key add -":
#    require => [ File["/etc/apt/sources.list"] ],
#  }

#  package { "puppet":
#    ensure => latest,
#    require => Exec["aptgetupdate"];
#  }

}
