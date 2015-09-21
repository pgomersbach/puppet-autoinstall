#!/bin/sh

###############################################################################
#                                                                             #	
# Nagios plugin to get qnap smart status via snmp                             #
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
	printf "Monitor plugin to get qnap smart status via snmp\n"
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
-d Disk numer to monitor > 0
EOT
}


###### MAIN ########

# Oid to monitor
oid=1.3.6.1.4.1.24681.1.2.11.1.7
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

       -d | --disk)
           if [[ -z "$2" ]]; then
               # Disk not provided
               printf "\nOption '$1' requires an argument"
               print_help
               exit $STATE_UNKNOWN
            else
	       disknum=$2
           fi
           shift 2
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

#Get the oid
STATUS=`${SENSORPROG} -v2c -On -c $community $host $oid.$disknum  2>/dev/null | cut -d " " -f4-`

# Verbose output
if [[ "$verbosity" -ge 2 ]]; then
   /bin/cat <<__EOT
Debugging information:
  Verbosity level: $verbosity
  Current status: $STATUS
__EOT
printf "\n\n"
fi


# And finally check against our thresholds
if [[ "$STATUS" =~ "GOOD" ]]; then
	echo "Disk $disknum OK S.M.A.R.T Status: $STATUS"
        exit $STATE_OK
elsif
	echo "Disk $disknum NOK S.M.A.R.T Status: $STATUS"
        exit $STATE_WARNING
fi

exit $STATE_UNKNOWN

