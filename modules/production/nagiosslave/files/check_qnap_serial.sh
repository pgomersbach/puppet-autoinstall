#!/bin/sh

###############################################################################
#                                                                             #	
# Nagios plugin to monitor hw serial with get_hwsn on qnap devices            #
# Written in Bash (and uses sed & awk).                                       #
#                                                                             #
###############################################################################

VERSION="Version 1.0"
AUTHOR="Paul Gomersbach (p.gomersbach@rely.nl)"

# Sensor program
SENSORPROG=/sbin/get_hwsn

# Exit codes
STATE_OK=0
STATE_WARNING=1
STATE_CRITICAL=2
STATE_UNKNOWN=3

# get_hwsn not working
exit $STATE_OK

shopt -s extglob

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
	printf "Monitor hw serial with get_hwsn on qnap devices\n"
/bin/cat <<EOT

Options:
-h
   Print detailed help screen
-V
   Print version information
-v
   Verbose output
EOT
}


###### MAIN ########

# See if we have the program installed and can execute it
if [[ ! -x "$SENSORPROG" ]]; then
	printf "\nIt appears you don't have get_hwsn installed \
	in $SENSORPROG\n"
	exit $STATE_UNKOWN
fi

# Parse command line options
while [[ -n "$1" ]]; do 
   case "$1" in

       -h | --help)
           print_help
           exit $STATE_OK
           ;;

       -V | --version)
           print_version
           exit $STATE_OK
           ;;

   esac
done



#Get the serial
TEMP=`${SENSORPROG}`
echo "Qnap serial: $TEMP"
exit $STATE_OK

