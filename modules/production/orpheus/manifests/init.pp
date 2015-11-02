# == class: orpheus
#
# full description of class orpheus here.
#
# === parameters
#
# document parameters here.
#
# [*sample_parameter*]
#   explanation of what this parameter affects and what it defaults to.
#   e.g. "specify one or more upstream ntp servers as an array."
#
# === variables
#
# here you should define a list of variables that this module would require.
#
# [*sample_variable*]
#   explanation of how this variable affects the funtion of this class and if it
#   has a default. e.g. "the parameter enc_ntp_servers must be set by the
#   external node classifier as a comma separated list of hostnames." (note,
#   global variables should not be used in preference to class parameters  as of
#   puppet 2.6.)
#
# === examples
#
#  class { orpheus:
#    servers => [ 'pool.ntp.org', 'ntp.local.company.com' ]
#  }
#
# === authors
#
# author name <author@domain.com>
#
# === copyright
#
# copyright 2011 your name here, unless otherwise noted.
#
class orpheus {
  host { 'orpheus-fw01.orpheus.nl':
    ip => '192.168.11.223',
    host_aliases => 'orpheus-fw01',
  }
  host { 'orp-pfs01.orpheus.local':
    ip => '192.168.180.1',
    host_aliases => 'orp-pfs01',
  }

}
