#!/bin/sh

###############################################################################
#                                                                             #	
# Nagios plugin to monitor number of hosts checks                             #
# Written in Bash (and uses sed & awk).                                       #
#                                                                             #
###############################################################################

VERSION="Version 1.0"
AUTHOR="Paul Gomersbach (p.gomersbach@rely.nl)"


# Exit codes
STATE_OK=0
STATE_WARNING=1
STATE_CRITICAL=2
STATE_UNKNOWN=3


#### Functions ####

# Print version information
print_version()
{
	printf "\n\n$0 - $VERSION\n"
}

#Print help information
print_help()
{
	print_version
	printf "$AUTHOR\n"
	printf "Monitor number of passive checks\n"
}

#Get the number of service checks
TEMP=`cat /tmp/nagiosslavehosts.conf | wc -l`
echo "OK - Host Checks: $TEMP|Total_Checks=$TEMP;;;"
exit $STATE_OK

