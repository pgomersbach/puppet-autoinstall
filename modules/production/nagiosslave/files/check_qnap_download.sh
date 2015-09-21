#!/bin/bash

###############################################################################
#                                                                             #	
# Nagios plugin to test maximum downloadspeed 			              #
# Written in Bash (and uses sed & awk).                                       #
#                                                                             #
###############################################################################

VERSION="Version 1.0"
AUTHOR="Paul Gomersbach (p.gomersbach@rely.nl)"

# Sensor program
SENSORPROG1=/usr/bin/wget

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
	printf "Nagios plugin to test maximum downloadspeed, tested on debian and qnap\n"
/bin/cat <<EOT

Options:
-h
   Print detailed help screen
-V
   Print version information
-v
   Verbose output

-url url
   url to read file from, for example http://speedtest.exsilia.net/100mb.bin or http://speedtest.onsbrabantnet.nl/files/100mb.bin
 
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
	printf "\nIt appears you don't have get_hd_temp installed in $SENSORPROG\n"
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

       -url)
	   if [[ -z "$2" ]]; then
		printf "\nOption $1 requires an argument"
		print_help
		exit $STATE_UNKNOWN
	   fi
		url=$2
           shift 2
           ;;

       *)
           printf "\nInvalid option '$1'"
           print_help
           exit $STATE_UNKNOWN
           ;;
   esac
done


# Check if a url were specified
if [[ -z "$url" ]]; then
	# No url to download were specified
	printf "\nNo url specified"
	print_help
	exit $STATE_UNKNOWN
fi


#Test the download url
TEMP=`${SENSORPROG1} $url -q --spider -O /dev/null`
if [ $? -gt 0 ]; then
	printf "\nUrl not reachable"
        print_help
	echo $?
        exit $STATE_UNKNOWN
else
	TEMP=`${SENSORPROG1} $url -O /dev/null -o /dev/null -b`
	sleep 1
	rxb1=`/sbin/ifconfig eth0|grep "RX bytes"| cut -d: -f2| cut -d" " -f1`
	sleep 5
	rxb2=`/sbin/ifconfig eth0|grep "RX bytes"| cut -d: -f2| cut -d" " -f1`
	if ps ax | grep -v grep | grep $SENSORPROG1 > /dev/null
	then
		pkill -P $$ wget
	else
    		echo "File to short to measure download speed"
		exit $STATE_UNKNOWN
	fi
fi

# Check if the tresholds has been set correctly
if [[ -z "$thresh_warn" || -z "$thresh_crit" ]]; then
	# One or both thresholds were not specified
	printf "\nThreshold not set"
	print_help
	exit $STATE_UNKNOWN
  elif [[ "$thresh_crit" -gt "$thresh_warn" ]]; then
	# The warning threshold must be higher than the critical threshold
	printf "\nWarning threshold should be higher than critical threshold"
	print_help
	exit $STATE_UNKNOWN
fi


# Verbose output
if [[ "$verbosity" -ge 2 ]]; then
   /bin/cat <<__EOT
Debugging information:
  Warning threshold: $thresh_warn 
  Critical threshold: $thresh_crit
  Verbosity level: $verbosity
  Current download speed sample1: $rxb1
  Current download speed sample2: $rxb2
__EOT
printf "\n\n"
fi

bytes5s=`expr $rxb2 - $rxb1`
TEMP=`expr $bytes5s / 5`

#TEMP=$rxb2 - $rxb1
# And finally check the results against our thresholds
if [[ "$TEMP" -lt "$thresh_crit" ]]; then
	# Download speed is below critical threshold
	echo "Download speed $url CRITICAL - Download speed is $TEMP Bps|Speed="$TEMP"B;$thresh_warn;$thresh_crit"
	exit $STATE_CRITICAL

  elif [[ "$TEMP" -lt "$thresh_warn" ]]; then
	# Download speed warning threshold
	echo "Download speed $url WARNING - Download speed is $TEMP Bps|Speed="$TEMP"B;$thresh_warn;$thresh_crit"
	exit $STATE_WARNING

  else
	# Download speed is ok
	echo "Download speed $url OK - Download speed is $TEMP Bps|Speed="$TEMP"B;$thresh_warn;$thresh_crit"
	exit $STATE_OK
fi
exit 3
