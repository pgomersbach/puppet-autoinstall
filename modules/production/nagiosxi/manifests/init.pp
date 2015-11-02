#
# nagiosxi module
#

class nagiosxi {
    case $operatingsystem {
        'centos': { include nagiosxi::install }
        'redhat': { include nagiosxi::install }
        default: { fail("No such operatingsystem: $operatingsystem yet defined") }
    }
}
