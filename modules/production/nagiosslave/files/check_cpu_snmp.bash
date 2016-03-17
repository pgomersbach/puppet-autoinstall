#!/bin/bash

#############################################################
# Nagios Linux/Windows CPU usage monitoring (using SNMP)
#############################################################
# Author  : Sunchai Rungruengchoosakul
# Date    : Feb 7, 2011
# Version : 1.0
# License : GPL
#############################################################
# Require:
#    - snmpwalk command
# 
# Check total cpu
# # snmpwalk -v 2c -c COMMUNITY x.x.x.x -On .1.3.6.1.2.1.25.3.3.1.1
#
# Check cpu usage
# # snmpwalk -v 2c -c COMMUNITY x.x.x.x -On .1.3.6.1.2.1.25.3.3.1.2
#
#############################################################
# Change Log :-
#    Make plugin with performance output :-)
#
# Performance specification : 'label'=value[UOM];[warn];[crit];[min];[max]
# Sample :DISK OK - free space: / 3326 MB (56%);| /=2643MB;5948;5958;0;5968
#
# From URL http://nagiosplug.sourceforge.net/developer-guidelines.html#AEN201
#############################################################

help () {

  echo "===================================="
  echo "check_cpu_snmp.bash"
  echo "===================================="
  echo "Author  : Sunchai Rungruengchoosakul "
  echo "Version : 1.0"
  echo "Date    : Feb 7, 2011"
  echo "===================================="
  echo "Option:-" 
  echo " -w  : CPU Usage warning (default 60%)"
  echo " -c  : CPU Usage critical (default 90%)"
  echo " -H* : Hostname / IP address"
  echo " -C* : SNMP Community string"
  echo " -d  : Debug option"
  echo " * is require parameter"
  exit 0
}

WARNING="60"
CRITICAL="90"
COMMUNITY=""
DESTINATION=""
DEBUG="n"

while getopts ":H:C:c:w:hd" Option
do
  case $Option in
    w )
      WARNING=$OPTARG
      ;;
    c )
      CRITICAL=$OPTARG
      ;;
    H )
      DESTINATION=$OPTARG
      ;;
    C ) 
      COMMUNITY=$OPTARG
      ;;
    h ) 
      help
      ;;
    d )
      DEBUG=y
      ;;
  esac
done
shift $(($OPTIND - 1))


# Check parameter
[ -z $COMMUNITY ] && help
[ -z $DESTINATION ] && help

# Show debug
[ $DEBUG == "y" ] && echo Community = $COMMUNITY
[ $DEBUG == "y" ] && echo Destination = $DESTINATION

#################
# Engine from report monitoring tools

# Make temp file
TMP_FILE=/tmp/CPU_RRD_$RANDOM

# Snmpwalk to HOSTMIB
snmpwalk -v 1 -c $COMMUNITY $DESTINATION -On .1.3.6.1.2.1.25.3.3.1.2 > $TMP_FILE

# Show debug
[ $DEBUG == "y" ] && echo "RAW snmp ==" && cat $TMP_FILE

# Summary all CPU Usage
AAA=`awk '{ sum += $4 }; END { print sum }' $TMP_FILE`

# Define total cpu
BBB=`wc -l $TMP_FILE | awk '{print $1}'`

# Fix problem with single cpu
[ -z ${BBB} ] && BBB="1"
[ "${BBB}" == "0" ] && BBB="1"

# Show debug
[ $DEBUG == "y" ] && echo "CPU USAGE TOTAL: "$AAA
[ $DEBUG == "y" ] && echo "CPU NUM: "$BBB

# Calculate total cpu usage
let "CCC = ${AAA}/${BBB}"

#echo "CPU USAGE AVG: "${CCC}

# Remove temp file
rm -f $TMP_FILE > /dev/null 2>&1

#################

# Unknow status
[ -z $CCC ] && echo "Cannot retrive information" && exit 3

# Sample from plugin ## time=0.627618s;;;0.000000 size=2016B;;;0
#                       'label'=value[UOM];[warn];[crit];[min];[max]
echo "CPU Usage : $CCC % |cpu=$CCC%;$WARNING;$CRITICAL;0;100"

# Normal status
[ $CCC -lt $WARNING ] && exit 0

# Warning status
[ $CCC -lt $CRITICAL ] && exit 1

# Critical status
[ $CCC -gt $CRITICAL ] && exit 2

