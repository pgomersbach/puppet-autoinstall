# == class: fiat
#
# full description of class fiat here.
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
#  class { fiat:
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
class fiat {
  host { 'internet.fiatauto.adfa.local':
    ip => '8.8.8.8',
    host_aliases => 'internet',
  }
  host { 'fgan_004p-xerox.fiatauto.adfa.local':
    ip => '151.92.23.233',
    host_aliases => 'fgan_004p-xerox',
  }
  host { 'fgan_002p-xerox.fiatauto.adfa.local':
    ip => '151.92.23.228',
    host_aliases => 'fgan_002p-xerox',
  }
  host { 'fgan_003p-xerox.fiatauto.adfa.local':
    ip => '151.92.23.252',
    host_aliases => 'fgan_003p-xerox',
  }
  host { 'fgan_005p-xerox.fiatauto.adfa.local':
    ip => '151.92.23.250',
    host_aliases => 'fgan_005p-xerox',
  }
  host { 'fgan_009p-xerox.fiatauto.adfa.local':
    ip => '151.92.23.222',
    host_aliases => 'fgan_009p-xerox',
  }
  host { 'fgan_008p-xerox.fiatauto.adfa.local':
    ip => '151.92.23.234',
    host_aliases => 'fgan_008p-xerox',
  }
  host { 'fgan_006p-xerox.fiatauto.adfa.local':
    ip => '151.92.23.238',
    host_aliases => 'fgan_006p-xerox',
  }
  host { 'fgan_010p-xerox.fiatauto.adfa.local':
    ip => '151.92.23.224',
    host_aliases => 'fgan_010p-xerox',
  }
  host { 'nl-fgac-p-01.fiatauto.adfa.local':
    ip => '151.92.23.248',
    host_aliases => 'nl-fgac-p-01',
  }
  host { 'ap2_02.fiatauto.adfa.local':
    ip => '10.89.137.5',
    host_aliases => 'ap2_02',
  }
  host { 'www.icanhazip.com':
    ip => '198.61.150.28',
  }

}
