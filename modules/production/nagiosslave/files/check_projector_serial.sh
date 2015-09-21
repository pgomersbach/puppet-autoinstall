#!/bin/sh

###############################################################################
#                                                                             #	
# Nagios plugin to get serial from projector via snmp                         #
# Written in Bash (and uses sed & awk).                                       #
#                                                                             #
###############################################################################

VERSION="Version 1.0"
AUTHOR="Paul Gomersbach (p.gomersbach@rely.nl)"

# Sensor program
SENSORPROG=/opt/bin/snmpget

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
	printf "Monitor serial from projector via snmp\n"
/bin/cat <<EOT

Options:
-h
   Print detailed help screen
-H 
   Hostname
-V
   Print version information
-v
   Verbose output
-o oid
   Oid to monitor standard = oid=enterprises.24391.1.3.6.0 (doremi serial number), oid=enterprises..2.1.1.4.1.1.1.0 (dolby serial number), etc
-w
   Exit with WARNING if serial is changed from last run
-c 
   Exit with CRITICAL if serial is changed from last run
EOT
}


###### MAIN ########

# Warning threshold
thresh_warn=0
# Critical threshold
thresh_crit=0
# Oid to monitor
doremi_oid=enterprises.24391.1.3.6.0
dolby_oid=1.3.6.1.4.1.6729.2.1.1.4.1.1.1.0
community=public

# See if we have the program installed and can execute it
if [[ ! -x "$SENSORPROG" ]]; then
	printf "\nIt appears you don't have snmpget installed \
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
           thresh_warn=1
	   shift 1
           ;;

-o | --oid)
           if [[ -z "$2" ]]; then
               # Oid not provided
               printf "\nOption '$1' requires an argument"
               print_help
               exit $STATE_UNKNOWN
            else
	       oid=$2
           fi
           shift 2
           ;;


       -c | --critical)
           thresh_crit=1
	   shift 1
           ;;

       -\?)
           print_help
           exit $STATE_OK
           ;;

       -H)
	   if [[ -z "$2" ]]; then
		printf "\nOption $1 requires an argument"
		print_help
		exit $STATE_UNKNOWN
	   fi
		host=$2
           shift 2
           ;;

       *)
           printf "\nInvalid option '$1'"
           print_help
           exit $STATE_UNKNOWN
           ;;
   esac
done


# Check if the tresholds has been set correctly

if [[ -z "$thresh_warn" && -z "$thresh_crit" ]]; then
	# Both thresholds were specified
	printf "\nThreshold not set"
	print_help
	exit $STATE_UNKNOWN
fi


#Get the oid
if [[ "$oid" ]]; then
  SERIAL=`${SENSORPROG} -v2c -On -c $community $host $oid  2>/dev/null | cut -d " " -f4-`
else
  TYPE="Doremi"
  SERIAL=`${SENSORPROG} -v2c -On -c $community $host $doremi_oid  2>/dev/null | cut -d " " -f4-`
  if [[ "$SERIAL" =~ .*Object.* ]]; then
    TYPE="Dolby"
    SERIAL=`${SENSORPROG} -v2c -On -c $community $host $dolby_oid  2>/dev/null | cut -d " " -f4-`
    if [[ "$SERIAL" =~ .*Object.* ]]; then
      TYPE="Cannot determine type of server"
    fi
  fi
fi

# Verbose outpu2t
if [[ "$verbosity" -ge 2 ]]; then
   /bin/cat <<__EOT
Debugging information:
  Warning threshold: $thresh_warn 
  Critical threshold: $thresh_crit
  Verbosity level: $verbosity
  Current serial: $SERIAL
  Current type: $TYPE
__EOT
printf "\n\n"
fi


# And finally check against our thresholds
if [[ "$SERIAL" ]]; then
	if [[ ! -r "/tmp/$host.serial" ]]; then
		# Save new serial
		echo $SERIAL > /tmp/$host.serial
		echo "$SERIAL $TYPE (new)"
		exit $STATE_OK
	else
		oldserial=$(/usr/bin/head -1 /tmp/$host.serial)
		if [[ "$oldserial" == "$SERIAL" ]]; then
			echo $SERIAL $TYPE
    			exit $STATE_OK
		else
			if [[ "$thresh_crit" == 1 ]]; then
				echo "Serial changed from: $oldserial to $SERIAL, to reset alarm remove /tmp/$host.serial from $host"
				exit $STATE_CRITICAL
			fi
			if [[ "$thresh_warn" == 1 ]]; then
       			        echo "Serial changed from: $oldserial to $SERIAL, to reset alarm remove /tmp/$host.serial from $host"
				exit $STATE_WARNING
       	 		fi
			# No warning or critical alarm set
			echo $SERIAL $TYPE
			exit $STATE_OK
		fi
	fi
fi

echo "$TYPE"
exit $STATE_UNKNOWN

