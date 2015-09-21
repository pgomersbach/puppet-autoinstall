#!/bin/sh

###############################################################################
#                                                                             #	
# Nagios plugin to test interface utilization  			              #
# Written in Bash (and uses sed & awk).                                       #
#                                                                             #
###############################################################################

VERSION="Version 1.1"
AUTHOR="Paul Gomersbach (p.gomersbach@rely.nl)"

# Sensor program
SENSORPROG1=/sbin/ifconfig

# Exit codes
STATE_OK=0
STATE_WARNING=1
STATE_CRITICAL=2
STATE_UNKNOWN=3

#shopt -s extglob ## Why?

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
	printf "Nagios plugin to test interface utilization, tested on debian and qnap\n"
/bin/cat <<EOT

Options:
-h
   Print detailed help screen
-V
   Print version information
-v
   Verbose output

-i 
   interface
 
-w INTEGER
   Exit with WARNING status if below INTEGER Mbps
-c INTEGER
   Exit with CRITICAL status if below INTEGER Mbps

EOT
}


###### MAIN ########

# Warning threshold
thresh_warn=
# Critical threshold
thresh_crit=

# See if we have the program installed and can execute it
if [ ! -x "$SENSORPROG1" ]; then
	printf "\nIt appears you don't have ifconfig installed \n"
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

       -v | --verbose)
           : $(( verbosity++ ))
           shift
           ;;

       -w | --warning)
           if [ -z "$2" ]; then
               # Threshold not provided
               printf "\nOption $1 requires an argument"
               print_help
               exit $STATE_UNKNOWN
            else
	       thresh=$2
           fi
           thresh_warn=$thresh
	   shift 2
           ;;

       -c | --critical)
           if [ -z "$2" ]; then
               # Threshold not provided
               printf "\nOption '$1' requires an argument"
               print_help
               exit $STATE_UNKNOWN
            else
	       thresh=$2
           fi
           thresh_crit=$thresh
	   shift 2
           ;;

       -\?)
           print_help
           exit $STATE_OK
           ;;

       -i)
	   if [[ -z "$2" ]]; then
		printf "\nOption $1 requires an argument"
		print_help
		exit $STATE_UNKNOWN
	   fi
		interface=$2
           shift 2
           ;;

       *)
           printf "\nInvalid option '$1'"
           print_help
           exit $STATE_UNKNOWN
           ;;
   esac
done


# Check if a interface were specified
if [[ -z "$interface" ]]; then
	# No interface were specified
	printf "\nNo interface specified"
	print_help
	exit $STATE_UNKNOWN
fi


rxb1=`/sbin/ifconfig $interface|grep "RX bytes"| cut -d: -f2| cut -d" " -f1`
sleep 5
rxb2=`/sbin/ifconfig $interface|grep "RX bytes"| cut -d: -f2| cut -d" " -f1`
ipaddrif=`/sbin/ifconfig $interface| grep "inet addr"| cut -d: -f2| cut -d" " -f1`

# Check if the tresholds has been set correctly
#if [[ -z "$thresh_warn" || -z "$thresh_crit" ]]; then
	# One or both thresholds were not specified
#	printf "\nThreshold not set"
#	print_help
#	exit $STATE_UNKNOWN
#  elif [[ "$thresh_crit" -gt "$thresh_warn" ]]; then
	# The warning threshold must be higher than the critical threshold
#	printf "\nWarning threshold should be higher than critical threshold"
#	print_help
#	exit $STATE_UNKNOWN
#fi


# Verbose output
if [[ "$verbosity" -ge 2 ]]; then
   /bin/cat <<__EOT
Debugging information:
  Warning threshold: $thresh_warn 
  Critical threshold: $thresh_crit
  Verbosity level: $verbosity
  Current speed sample1: $rxb1
  Current speed sample2: $rxb2
__EOT
printf "\n\n"
fi

bytes5s=`/usr/bin/expr $rxb2 - $rxb1`
TEMP=`/usr/bin/expr $bytes5s / 5`

#TEMP=$rxb2 - $rxb1
# And finally check the results against our thresholds
if [[ "$TEMP" -lt "$thresh_crit" ]]; then
	# Download speed critical threshold
	echo "$interface CRITICAL - Utilization is high IP address: $ipaddrif|Speed="$TEMP";$thresh_warn;$thresh_crit"
	exit $STATE_CRITICAL

  elif [[ "$TEMP" -lt "$thresh_warn" ]]; then
	# Download speed warning threshold
	echo "$interface WARNING - Utilization is medium IP address: $ipaddrif|Speed="$TEMP";$thresh_warn;$thresh_crit"
	exit $STATE_WARNING

  else
	# Download speed is ok
	echo "$interface UP - Utilization is low IP address: $ipaddrif|Speed="$TEMP";$thresh_warn;$thresh_crit"
	exit $STATE_OK
fi
exit 3
