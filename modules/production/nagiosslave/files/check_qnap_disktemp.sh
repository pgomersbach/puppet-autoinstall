#!/bin/sh

###############################################################################
#                                                                             #	
# Nagios plugin to monitor disk temperature with get_hd_temp on qnap devices  #
# Written in Bash (and uses sed & awk).                                       #
#                                                                             #
###############################################################################

VERSION="Version 1.0"
AUTHOR="Paul Gomersbach (p.gomersbach@rely.nl)"

# Sensor program
SENSORPROG=/sbin/get_hd_temp

# Exit codes
STATE_OK=0
STATE_WARNING=1
STATE_CRITICAL=2
STATE_UNKNOWN=3

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
	printf "Monitor disk temperature with get_hd_temp on qnap devices\n"
/bin/cat <<EOT

Options:
-h
   Print detailed help screen
-V
   Print version information
-v
   Verbose output

--disk NUM
   Set which disk to monitor, for example 0 or 1. Default is 0
 
-w INTEGER
   Exit with WARNING status if above INTEGER degres
-c INTEGER
   Exit with CRITICAL status if above INTEGER degres
EOT
}


###### MAIN ########

# Warning threshold
thresh_warn=
# Critical threshold
thresh_crit=
# Hardware to monitor
disk=0

# See if we have the program installed and can execute it
if [[ ! -x "$SENSORPROG" ]]; then
	printf "\nIt appears you don't have get_hd_temp installed \
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

       -v | --verbose)
           : $(( verbosity++ ))
           shift
           ;;

       -w | --warning)
           if [[ -z "$2" ]]; then
               # Threshold not provided
               printf "\nOption $1 requires an argument"
               print_help
               exit $STATE_UNKNOWN
            elif [[ "$2" = +([0-9]) ]]; then
               # Threshold is an integer 
               thresh=$2
            else
               # Threshold is not an integer
               printf "\nThreshold must be an integer"
               print_help
               exit $STATE_UNKNOWN
           fi
           thresh_warn=$thresh
	   shift 2
           ;;

       -c | --critical)
           if [[ -z "$2" ]]; then
               # Threshold not provided
               printf "\nOption '$1' requires an argument"
               print_help
               exit $STATE_UNKNOWN
            elif [[ "$2" = +([0-9]) ]]; then
               # Threshold is an integer 
               thresh=$2
            else
               # Threshold is not an integer
               printf "\nThreshold must be an integer"
               print_help
               exit $STATE_UNKNOWN
           fi
           thresh_crit=$thresh
	   shift 2
           ;;

       -\?)
           print_help
           exit $STATE_OK
           ;;

       --disk)
	   if [[ -z "$2" ]]; then
		printf "\nOption $1 requires an argument"
		print_help
		exit $STATE_UNKNOWN
	   fi
		disk=$2
           shift 2
           ;;

       *)
           printf "\nInvalid option '$1'"
           print_help
           exit $STATE_UNKNOWN
           ;;
   esac
done


# Check if a sensor were specified
if [[ -z "$disk" ]]; then
	# No sensor to monitor were specified
	printf "\nNo sensor specified"
	print_help
	exit $STATE_UNKNOWN
fi


#Get the temperature
TEMP=`${SENSORPROG} $disk`

# Check if the tresholds has been set correctly
if [[ -z "$thresh_warn" || -z "$thresh_crit" ]]; then
	# One or both thresholds were not specified
	printf "\nThreshold not set"
	print_help
	exit $STATE_UNKNOWN
  elif [[ "$thresh_crit" -lt "$thresh_warn" ]]; then
	# The warning threshold must be lower than the critical threshold
	printf "\nWarning temperature should be lower than critical"
	print_help
	exit $STATE_UNKNOWN
fi


# Verbose outpu2t
if [[ "$verbosity" -ge 2 ]]; then
   /bin/cat <<__EOT
Debugging information:
  Warning threshold: $thresh_warn 
  Critical threshold: $thresh_crit
  Verbosity level: $verbosity
  Current disk $disk temperature: $TEMP
__EOT
printf "\n  Temperature lines directly from sensors:\n"
${SENSORPROG} $disk
printf "\n\n"
fi


# And finally check the temperature against our thresholds
if [[ "$TEMP" -gt "$thresh_crit" ]]; then
	# Temperature is above critical threshold
	echo "Disk $disk CRITICAL - Temperature is $TEMP|Temp="$TEMP";$thresh_warn;$thresh_crit"
	exit $STATE_CRITICAL

  elif [[ "$TEMP" -gt "$thresh_warn" ]]; then
	# Temperature is above warning threshold
	echo "Disk $disk WARNING - Temperature is $TEMP|Temp="$TEMP";$thresh_warn;$thresh_crit"
	exit $STATE_WARNING

  else
	# Temperature is ok
	echo "Disk $disk OK - Temperature is $TEMP|Temp="$TEMP";$thresh_warn;$thresh_crit"
	exit $STATE_OK
fi
exit 3
