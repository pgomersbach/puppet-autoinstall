#!/bin/bash
#########################################################
#							#
#		SNMP Printer Check			#
#							#
# check_snmp_printer					#
# 	Version 3.141592 (December 12, 2011)			#
#							#
# Authored by Jason Leonard				#
# 	E-mail: jason_leonard@yahoo.com			#
#							#
# Overview						#
# ----------------------------------------------------- #
#	This plugin is a rewrite of the SNMP printer	#
# check provided by Monitoring Solutions. In operating	#
# the plugin at our environment, I noticed the output	#
# was combined as one long paragraph when using	the 	#
# CONSUM ALL option (definitely a favorite of mine).	#
# While this is in accordance with Nagios plugin dev.	#
# guidelines, for devices with numerous consumables 	#
# (like copiers), this makes it difficult to quickly	#
# find the empty consumable when an alert came in. So I #
# set out to spruce up the output of the plugin - using #
# one consumable per line.				#
#							#
#	In the process, I also realized the original 	#
# plugin was more if/then statements than I had seen 	#
# since my programming class in college. So I made the 	#
# code a bit cleaner for faster execution. I also had	#
# add SNMP pre-flight checks, as the original would 	#
# return OK status to Nagios even if SNMP was broken. 	#
#							#
#	Lastly, I decided to rewrite the options and	#
# add other pre-flight checks that are present in my 	#
# other plugins. I like to be thorough in making sure 	#
# the program won't return output if the input is just	#
# garbage!						#
#							#
# NOTE:							#
#	Because CONSUM ALL uses a multi-line output, 	#
# you will need to use the $LONGSERVICEOUTPUT$ macro 	#
# in your service notification commands!		#
#							#
# This plugin is distributed under the GNU GPL license.	#
# You may re-destribute only according to the terms of 	#
# the GNU GPL v2.					#
#							#
#########################################################

#########################################################
##		     GLOBAL VARIABLES 		       ##
#########################################################
APPNAME=$(basename $0)
VERSION="3.14159"
COMMUNITY="public"
EXIT_CODE=0
EXIT_STRING=""

STRING_TYPE=""
PERFDAT=""
CHECK=""
PARAMETER=""

# Set a warning at 20% of consumable, if not passed
WARNING=20

# Set a critical at 5% of consumable, if not passed. The standard of 10 
# seems to be high for most consumables, which move very slowly.
CRITICAL=5

# Change this to modify the script's handling of how it separates
# each consumable/tray when multiple checks are output.
# SEPARATOR="\n"
SEPARATOR=" "

# This is the character that tokenizes multiple arguments
# to the TRAY and CONSUM checks. I have this here
# so it's easy to change if I find the current character
# I have is buggy or a bad choice
ARG_TOKEN=","


#########################################################
##		    print_help Function		       ##
#########################################################
# Prints out user help and gives examples of proper	#
# plugin usage						#
#########################################################

function print_help {
	echo 'SNMP Printer Check for Nagios'
	echo ''
	echo 'This plugin is not developped by the Nagios Plugin group.'
	echo 'Please do not e-mail them for support on this plugin.'
	echo ''
	echo 'For contact info, please read the plugin script file.'
	echo ''
	echo "Usage of $APPNAME"
	echo " $APPNAME -H <host/IP> -C <community> -x <check> [-w] [-c] [-S] | -h | -V "
	echo '---------------------------------------------------------------------'
	echo 'Usable Options:'
	echo '' 
	echo '	 -C <community>'
	echo '	     The SNMP Community variable - use the name of your SNMP community with read privileges'
	echo '	     By default, the community is assumed to be public'
	echo '	 -H <hostname>'
	echo '	 (required option)'
	echo '	     The IP address or hostname of the system to check'
	echo '	 -S <text string>'
	echo '	     assign a particular string as the separator for consumables.'
	echo '	     Default is " " to conform to Nagios plugin development guidelines'
	echo '	 -w <warn>'
	echo '       warning threshold (% of consumable remaining)'
	echo '	 -c <crit>'
	echo '	     critical threshold (% of consumable remaining)'
	echo '	 -h'
	echo '	     show this help screen'
	echo '	 -V'
	echo '	     show the current version of the plugin'
	echo '	 -x <check>'     
	echo '	 (required option)'
	echo '	     The check you want to perform for the printer. Choose from the following:'
	echo ''
	echo '	         CONSUM {<string> | TEST | ALL}'
	echo '	 	         <string> will give you all consumables matching the string '
	echo "	             	For example, 'CONSUM Toner' will only show toner levels"
	echo '	             TEST will give you the exact names of available consumables'
	echo '	                 For example,'
	echo '	                     Black Toner Cartridge HP C4191A'
	echo '	                 To monitor a consumable, call the function as follows:'
	echo "	 				    $APPNAME -H <hostname> -C <community> -x \"CONSUM Black\" "
	echo '	             ALL gives you all consumable output at once.'
	echo ''
	echo '	         CONSUMX <string>'
	echo '	                this gives you results only for the ***EXACT*** consumable specified by <string>'
	echo '	                     For example, '
	echo '	                          CONSUMX "Black Toner Cartridge" '
	echo '	                     will only give you the usage for a consumable named "Black Toner Cartridge". '
	echo '	                     It will not give you results for "Black Toner Cartridge 1" or "Black Toner". '
	echo '	         DISPLAY'
	echo '	                Report contents of printer display'
	echo ''
	echo '	         DEVICES'
	echo '	                Status of hardware modules'
	echo ''
	echo '	         MESSAGES'
	echo '	                Event logs reported by the printer'
	echo ''
	echo '	         MODEL'
	echo '	                ALL will give you all tray output at once.'
	echo ''
	echo '	         PAGECOUNT'
	echo '	                How many pages this printer has processed (culmulative)'
	echo ''
	echo '	         STATUS'
	echo '	                Overall status of the printer'
	echo ''
	echo '	         TRAY {<number> | TEST | ALL}'
	echo '	                <number> will give you output for the specified tray. A comma-separated list of values is possible as well.'
	echo "	                TEST will give you the #'s of all trays available "
	echo '	                ALL will give you all tray output at once.'
	echo ''
	echo 'Examples:'
	echo "    $APPNAME -H 10.0.1.10 -C public -x \"CONSUM ALL\" -w 25 -c 10 "
	echo "    $APPNAME -H 10.0.1.10 -C public -x \"CONSUMX Punch Dust Box\" "
	echo "    $APPNAME -H 10.0.1.10 -C public -x MODEL "
	echo "    $APPNAME -H 10.0.1.10 -C public -x \"TRAY 2,3\" "
	echo "    $APPNAME -V"
	echo ''
	echo '---------------------------------------------------------------------'

	return 3
}

#########################################################
##		   check_model function		       ##
#########################################################
# Returns printer model and serial. Always returns OK 	#
#########################################################

function check_model(){
#	Vendor specific items to code here!
#		possibly serial #
	MODEL=$(snmpget -v1 -Ovq -c $COMMUNITY $HOST_NAME 1.3.6.1.2.1.25.3.2.1.3.1 2>/dev/null)
	SERIAL=$(snmpwalk -v1 -Ovq -c $COMMUNITY $HOST_NAME 1.3.6.1.2.1.43.5.1.1.17 2>/dev/null | tr -d "\"")
	
	EXIT_STRING="$MODEL, Serial # $SERIAL"
	return 0
}

#########################################################
##		  check_messages function	       ##
#########################################################
# Shows messages on the printer display. The OID is not #
# commonly used in all printers				#
#########################################################

function check_messages(){
	MESSAGES=$(snmpwalk -v1 -Ovq -c $COMMUNITY $HOST_NAME 1.3.6.1.2.1.43.18.1.1.8 2>/dev/null | tr -d "\"" | tr "\n" "\!")
	if [ -z "$MESSAGES" ]; then
		EXIT_STRING="UNKNOWN: Can't determine messages. Device does not support this OID.\n"
		EXIT_CODE=3
	else
		EXIT_STRING="$MESSAGES"
	fi
	
	return $EXIT_CODE

}

#########################################################
##		 check_page_count function	       ##
#########################################################
# Returns pretty-formatted page count for the printer.	#
# Awesome for tracking historical page usage.		#
#########################################################

function check_page_count(){
	PAGE_COUNT=$(snmpget -v1 -Ovq -c $COMMUNITY $HOST_NAME 1.3.6.1.2.1.43.10.2.1.4.1.1 2>/dev/null | sed -e :x -e 's/\([0-9][0-9]*\)\([0-9][0-9][0-9]\)/\1,\2/' -e 'tx')
	
	EXIT_STRING="Pagecount is $PAGE_COUNT"
	PERFDAT="Pages=$PAGE_COUNT;"
	return 0
}



#########################################################
## 		  check_display function 	       ##
#########################################################
#							#
#########################################################

function check_display(){

	DISPLAY=$(snmpwalk -v1 -Ovq -c $COMMUNITY $HOST_NAME 1.3.6.1.2.1.43.16.5.1.2.1 2>/dev/null | tr -d "\"" )

	# if display is null, we need to let the user know
	if [ $? -eq 0 ]; then
		# Let's make sure we eliminate any extra new lines, or at least replace them with our
		#	specified SEPARATOR (which could be a new line)
		EXIT_STRING=$(echo "$DISPLAY" | tr "\n" "$SEPARATOR")
		return 0
	else
		# Something happened or this OID isn't available
		EXIT_STRING="UNKNOWN - printer does not appear to support using this OID."
		return 3
	fi

}

#########################################################
##	        check_printer_status function 	       ##
#########################################################
#							#
#########################################################

function check_printer_status(){

	STATUS_EXIT_CODE=0
	PRINTER_STATUS=$(snmpget -v1 -Ovq -c $COMMUNITY $HOST_NAME 1.3.6.1.2.1.25.3.5.1.1.1 2>/dev/null)
	
	case "$PRINTER_STATUS" in
		"other(1)")
			EXIT_STRING="CRITICAL: Printer status is $PRINTER_STATUS"
			STATUS_EXIT_CODE=2
		;;
		"idle(3)")
			EXIT_STRING="OK: Printer status is $PRINTER_STATUS"
		;;
		"printing(4)")
			EXIT_STRING="OK: Printer status is $PRINTER_STATUS"
		;;
		"warmup(5)")
			EXIT_STRING="OK: Printer status is $PRINTER_STATUS"
		;;
		*)
			EXIT_STRING="WARNING: Printer status is $PRINTER_STATUS"
			STATUS_EXIT_CODE=1
		;;
	esac
	
	return $STATUS_EXIT_CODE
}

#########################################################
## 		check_device_status function 	       ##
#########################################################
#							#
#########################################################

function check_device_status(){

	CURRENT_EXIT_CODE=0
	CURRENT_STATUS=0
	DEVICE_STATUS=""
	DEVICE_NAME=""
	DEVICE_IDS=$(snmpwalk -v1 -On -c $COMMUNITY $HOST_NAME 1.3.6.1.2.1.25.3.2.1.1 2>/dev/null)

	# create this around a for loop on id's, which come from .1.3.6.1.2.1.25.3.2.1.1.x
	for ID in $(echo $DEVICE_IDS | egrep -oe '[[:digit:]]+\ =' | cut -d " " -f1)
	do
		DEVICE_NAME=$(snmpget -v1 -Ovq -c $COMMUNITY $HOST_NAME 1.3.6.1.2.1.25.3.2.1.3.$ID 2>/dev/null)
		EXIT_STRING="$EXIT_STRING$DEVICE_NAME status is "
		
		DEVICE_STATUS=$(snmpget -v1 -Ovq -c $COMMUNITY $HOST_NAME 1.3.6.1.2.1.25.3.2.1.5.$ID 2>/dev/null)

		case "$DEVICE_STATUS" in
			"unknown(1)")
				EXIT_STRING="$EXIT_STRING$DEVICE_STATUS - WARNING!$SEPARATOR"
				CURRENT_STATUS=1
			;;
			"running(2)")
				EXIT_STRING="$EXIT_STRING$DEVICE_STATUS - OK!$SEPARATOR"
			;;
			"warning(3)")
				EXIT_STRING="$EXIT_STRING$DEVICE_STATUS - WARNING!$SEPARATOR"
				CURRENT_STATUS=1
			;;
			"testing(4)")
				EXIT_STRING="$EXIT_STRING$DEVICE_STATUS - OK!$SEPARATOR"
			;;
			"down(5)")
				EXIT_STRING="$EXIT_STRING$DEVICE_STATUS - CRITICAL!$SEPARATOR"
				CURRENT_STATUS=2
			;;
			*)
				EXIT_STRING="$EXIT_STRING$DEVICE_STATUS - WARNING!$SEPARATOR"
				CURRENT_STATUS=1
			;;
		esac
		
		if [ "$CURRENT_STATUS" -gt "$CURRENT_EXIT_CODE" ]; then
			CURRENT_EXIT_CODE="$CURRENT_STATUS"
		fi

	done
	
	return $CURRENT_EXIT_CODE

} 

#########################################################
##	      check_one_consumable function	       ##
#########################################################
# Given the marker's ID (1, 2, 3, etc.), this function	#
# grabs the consmable string for that ID, converts it 	#
# to a name and determines capacity and status code for	#
# it.							#
#							#
# Only status code is returned. Global string variables #
# are used for printing and other functionality.	#
#########################################################

function check_one_consumable () {

	local CONSUM_EXIT_CODE=0
	CURRENT_CAPACITY=0
	MAX_CAPACITY=0
	MARKER_NAME=""
	MARKER_COLOR=""
	MARKER_STRING=$(snmpget -v1 -On -c $COMMUNITY $HOST_NAME 1.3.6.1.2.1.43.11.1.1.6.1.$1 2>/dev/null)

	# We'll be parsing our name differently depending on whether we have Hex-String or not
	if [ "$STRING_TYPE" == "Hex-STRING:" ]; then
		MARKER_NAME=$(echo "$MARKER_STRING" | cut -d ":" -f2- | tr -d "\n" | xxd -r -p)
	else
		MARKER_NAME=$(echo "$MARKER_STRING" | cut -d " " -f4- | tr -d "\"")
	fi

	# Some manufacturers don't put the actual cartridge color in the above OID text for 
	#	MARKER_STRING. Instead, each entry just says "toner". The OID used here is 
	#	a place where an associated color string must be stored. We are going to get this 
	#	info. and use it if not already available in the MARKER_NAME we've parsed.
	# --- Thanks to Martin Šoltis for letting me know about this problem on some copiers.
	GETCOLOR=$(snmpget -v1 -c $COMMUNITY $HOST_NAME 1.3.6.1.2.1.43.12.1.1.4.1.$1 2>/dev/null)
	MARKER_COLOR=$(echo $GETCOLOR | cut -d " " -f4- | tr -d "\"")
	
	# We're just checking here to see if the consumable already has this color in its text description
	if [ $(echo "$MARKER_NAME" | grep -vqi "$MARKER_COLOR") ]; then
		# It doesn't, so we're going to add it
		MARKER_NAME="$MARKER_COLOR $MARKER_NAME"
	fi

	# As usual, if the results are an empty set, something went wrong or didn't match up
	if [ -z "$MARKER_NAME" ]; then 
		EXIT_STRING="UNKNOWN - OID not found! Your printer may not support checking this consumable."
		EXIT_STRING="$EXIT_STRING Use the CONSUM TEST option to determine which consumables may be monitored."
		PERFDAT=""
		CONSUM_EXIT_CODE=3
	else
		# Determine capacities for the current marker
		CURRENT_CAPACITY=$(snmpget -v1 -Ovq -c $COMMUNITY $HOST_NAME 1.3.6.1.2.1.43.11.1.1.9.1.$1 2>/dev/null)
		MAX_CAPACITY=$(snmpget -v1 -Ovq -c $COMMUNITY $HOST_NAME 1.3.6.1.2.1.43.11.1.1.8.1.$1 2>/dev/null)
		if [ "$MAX_CAPACITY" -lt 0 ]; then
			MAX_CAPACITY=0
		fi
		
		# the component does not have a measurable status indication
		case "$CURRENT_CAPACITY" in
			"-3") # A value of (-3) means that the printer knows that there is some supply/remaining space
				EXIT_STRING="$EXIT_STRING$MARKER_NAME is OK!$SEPARATOR"
			;;
			"-2") # The value (-2) means unknown
				EXIT_STRING="$EXIT_STRING$MARKER_NAME is at WARNING level!$SEPARATOR"
				if [ "$CONSUM_EXIT_CODE" -lt 1 ]; then
					CONSUM_EXIT_CODE=1
				fi
			;;
			"0") # Something is empty!
				EXIT_STRING="$EXIT_STRING$MARKER_NAME is at CRITICAL level!$SEPARATOR"
				CONSUM_EXIT_CODE=2
			;;
			*) # A positive value means this is a measurable component - let's report it's status code and let user know the % usage
				let "CURRENT_CAPACITY=$CURRENT_CAPACITY * 100 / $MAX_CAPACITY"
				if [ "$CURRENT_CAPACITY" -gt "$WARNING" ]; then 
					EXIT_STRING="$EXIT_STRING$MARKER_NAME is at $CURRENT_CAPACITY%% - OK!$SEPARATOR"
				else 
					if [ "$CURRENT_CAPACITY" -le "$WARNING" ] && [ "$CURRENT_CAPACITY" -gt "$CRITICAL" ]; then
						EXIT_STRING="$EXIT_STRING$MARKER_NAME is at $CURRENT_CAPACITY%% - WARNING!$SEPARATOR"
						if [ "$CONSUM_EXIT_CODE" -lt 1 ]; then
							CONSUM_EXIT_CODE=1
						fi
					else 
						if [ "$CURRENT_CAPACITY" -le "$CRITICAL" ]; then
							EXIT_STRING="$EXIT_STRING$MARKER_NAME is at $CURRENT_CAPACITY%% - CRITICAL!$SEPARATOR"
							CONSUM_EXIT_CODE=2
						fi
					fi
				fi						
			;;
		esac	
		
		PERFDAT="$PERFDAT $MARKER_NAME=$CURRENT_CAPACITY;$WARNING;$CRITICAL;"
		
	fi
	
	return $CONSUM_EXIT_CODE
				
}

#########################################################
##	      check_exact_consumable function	       ##
#########################################################
# Loops through all consumables and compares the string #
# passed to the consumable string. If a match is found, #
# we calculate and output capacity and status. If a	#
# match is not found, let the user know.		#
#							#
# Global string variables are used for printing status 	#
# and perf data.					#
#########################################################

function check_exact_consumable(){

	local CONSUMX_EXIT_CODE=0
	FOUND=false
	FOUND_MARKER=0
	
	# Now we can loop through everything that matched
	for MARKER_ID in $(echo "$ALL_MARKERS" | egrep -oe '[[:digit:]]+\ =' | cut -d " " -f1)
	do
		MARKER_STRING=$(snmpget -v1 -On -c $COMMUNITY $HOST_NAME 1.3.6.1.2.1.43.11.1.1.6.1.$MARKER_ID 2>/dev/null)

		# We'll be parsing our name differently depending on whether we have Hex-String or not
		if [ "$STRING_TYPE" == "Hex-STRING:" ]; then
			MARKER_NAME=$(echo "$MARKER_STRING" | cut -d ":" -f2- | tr -d "\n" | xxd -r -p)
		else
			MARKER_NAME=$(echo "$MARKER_STRING" | cut -d " " -f4- | tr -d "\"")
		fi

		# Update our boolean if we find a match!
		if [ "$1" == "$MARKER_NAME" ]; then
			FOUND=true
			FOUND_MARKER="$MARKER_ID"
		fi

	done

	if $FOUND; then
		# Determine capacities for the marker of the matching consumable
		X_CURRENT_CAPACITY=$(snmpget -v1 -Ovq -c $COMMUNITY $HOST_NAME 1.3.6.1.2.1.43.11.1.1.9.1.$FOUND_MARKER 2>/dev/null)
		MAX_CAPACITY=$(snmpget -v1 -Ovq -c $COMMUNITY $HOST_NAME 1.3.6.1.2.1.43.11.1.1.8.1.$FOUND_MARKER 2>/dev/null)
		if [ "$MAX_CAPACITY" -lt 0 ]; then
			MAX_CAPACITY=0
		fi
		
		# the component does not have a measurable status indication
		case "$X_CURRENT_CAPACITY" in
			"-3") # A value of (-3) means that the printer knows that there is some supply/remaining space
				EXIT_STRING="$EXIT_STRING$1 is OK!\n"
			;;
			"-2") # The value (-2) means unknown
				EXIT_STRING="$EXIT_STRING$1 is at WARNING level!$SEPARATOR"
				if [ "$CONSUMX_EXIT_CODE" -lt 1 ]; then
					CONSUMX_EXIT_CODE=1
				fi
			;;
			"0") # Something is empty!
				EXIT_STRING="$EXIT_STRING$1 is at CRITICAL level!$SEPARATOR"
				CONSUMX_EXIT_CODE=2
			;;
			*) # A positive value means this is a measurable component - let's report it's status code and let user know the % usage
				let "X_CURRENT_CAPACITY=$X_CURRENT_CAPACITY * 100 / $MAX_CAPACITY"
				if [ "$X_CURRENT_CAPACITY" -gt "$WARNING" ]; then 
					EXIT_STRING="$EXIT_STRING$1 is at $X_CURRENT_CAPACITY%% - OK!$SEPARATOR"
				else 
					if [ "$X_CURRENT_CAPACITY" -le "$WARNING" ] && [ "$X_CURRENT_CAPACITY" -gt "$CRITICAL" ]; then
						EXIT_STRING="$EXIT_STRING$1 is at $X_CURRENT_CAPACITY%% - WARNING!$SEPARATOR"
						if [ "$CONSUMX_EXIT_CODE" -lt 1 ]; then
							CONSUMX_EXIT_CODE=1
						fi
					else 
						if [ "$X_CURRENT_CAPACITY" -le "$CRITICAL" ]; then
							EXIT_STRING="$EXIT_STRING$1 is at $X_CURRENT_CAPACITY%% - CRITICAL!$SEPARATOR"
							CONSUMX_EXIT_CODE=2
						fi
					fi
				fi						
			;;
		esac
		PERFDAT="$PERFDAT $1=$X_CURRENT_CAPACITY;$WARNING;$CRITICAL;"
	else
		# Let the user know we didn't find anything, and report back the string they sent. Also prompt them to run the TEST option to double-check their string
		EXIT_STRING="UNKNOWN - No match found for '$1'! Use the CONSUM TEST option to determine which consumables may be monitored.\n"
		CONSUMX_EXIT_CODE=3
	fi
		
	return $CONSUMX_EXIT_CODE

}

#########################################################
##		check_consumables function	       ##
#########################################################
# Determines which consumables to check and then pass 	#
# them all off to check_one_consumable			#
#							#
# Global string variables are used for printing status 	#
# and perf data.					#
#########################################################

function check_consumables(){

	local CONSUMS_EXIT_CODE=0
	HEX_ID=0
	CURRENT_STATUS=0
	HEX_MARKER=""
	ASCII_MARKER=""
	MARKERS_MATCHED=""

	case "$1" in
		"TEST")	# User passed "TEST" parameter - output what consumables are available
			printf "Consumables you may monitor:\n"
			
			if [ "$STRING_TYPE" == "Hex-STRING:" ]; then
				for HEX_ID in $(echo "$ALL_MARKERS" | egrep -oe '[[:digit:]]+\ =' | cut -d " " -f1)
				do
					HEX_MARKER=$(snmpget -v1 -On -c $COMMUNITY $HOST_NAME 1.3.6.1.2.1.43.11.1.1.6.1.$HEX_ID 2>/dev/null)
					ASCII_MARKER=$(echo "$HEX_MARKER" | cut -d ":" -f2 | tr -d "\n" | xxd -r -p)
					EXIT_STRING="$EXIT_STRING$ASCII_MARKER\n"
				done
			else
				EXIT_STRING=$(snmpwalk -v1 -Ovq -c $COMMUNITY $HOST_NAME 1.3.6.1.2.1.43.11.1.1.6.1 2>/dev/null)
			fi
			
			CONSUMS_EXIT_CODE=3
		;;
		"ALL") # User passed ALL parameter - check everything!
			# Let's loop through all consumables available
			for MARKER_ID in $(echo "$ALL_MARKERS" | egrep -oe '[[:digit:]]+\ =' | cut -d " " -f1)
			do
				check_one_consumable "$MARKER_ID"
				CURRENT_STATUS=$?
				
				if [ "$CURRENT_STATUS" -gt "$CONSUMS_EXIT_CODE" ]; then
					CONSUMS_EXIT_CODE="$CURRENT_STATUS"
				fi
			done
		;;
		*) # A string was passed, on which we will match to available consumable strings
			if [ "$STRING_TYPE" == "Hex-STRING:" ]; then
				# If our printer uses Hex-STRING fields, we need to convert our user's string to hex first
				HEX_STRING=$(echo "$1" | tr -d "\n" | xxd -p -u)
				
				# Now that we have a hex string for the user string, we need look for it in output that is formatted similarly 
				#	XXD -p doesn't output spaces, but the Hex-STRING fields do use spaces between each byte
				MARKERS_MATCHED=$(echo "$ALL_MARKERS" | tr -d " " | egrep -i "$HEX_STRING")
			else
				MARKERS_MATCHED=$(echo "$ALL_MARKERS" | egrep -i "$1")
			fi

			if [ -z "$MARKERS_MATCHED" ]; then
				EXIT_STRING="UNKNOWN - OID not found! Your printer may not support checking this consumable."
				EXIT_STRING="$EXIT_STRING Use the CONSUM TEST option to determine which consumables may be monitored."
				PERFDAT=""
				EXIT_CODE=3
			else
				# Now we can loop through everything that matched
				for MARKER_ID in $(echo "$MARKERS_MATCHED" | cut -d "=" -f1 | cut -d "." -f14)
				do
					check_one_consumable "$MARKER_ID"

					CURRENT_STATUS=$?
					
					if [ "$CURRENT_STATUS" -gt "$CONSUMS_EXIT_CODE" ]; then
						CONSUMS_EXIT_CODE="$CURRENT_STATUS"
					fi
				done
			fi
		;;
	esac
	
	return $CONSUMS_EXIT_CODE

}

#########################################################
##		  check_one_tray Function	       ##
#########################################################
# Checks the tray #, as passed by parameter. If found,	#
# it returns the status and capacity. 			#
#							#
# Only status code is returned. Global string variables #
# are used for printing and other functionality.	#
#########################################################

function check_one_tray (){

	TRAY_EXIT_CODE=0
	TRAY_CAPACITY=0
	TRAY_MAX_CAPACITY=0
	TRAY_FEED_DIMENSION=0
	TRAY_XFEED_DIMENSION=0
	TRAY_DIMENSION_UNITS=0
	
	TRAY_CAPACITY=$(snmpwalk -v1 -Ovq -c $COMMUNITY $HOST_NAME 1.3.6.1.2.1.43.8.2.1.10.1.$1 2>/dev/null)
	if [ -z "$TRAY_CAPACITY" ]; then
		EXIT_STRING="$EXIT_STRING UNKNOWN - Tray $1 not found. Use the TRAY TEST option to determine which trays may be monitored.\n"
		TRAY_EXIT_CODE=3
	else
		# Determine information about the tray
		TRAY_NAME=$(snmpwalk -v1 -Ovq -c $COMMUNITY $HOST_NAME 1.3.6.1.2.1.43.8.2.1.13.1.$1 2>/dev/null)
		
		# Some manufacturers do not set the tray name OID, so we'll assume a generic name depending on the # passed to the function
		if [ "$TRAY_NAME"=="" ]; then
			TRAY_NAME="Tray $1"
		fi
		
		case "$TRAY_CAPACITY" in
			"-3") # The value (-3) means that the printer knows that at least one unit remains.
				EXIT_STRING="$EXIT_STRING$TRAY_NAME is OK!$SEPARATOR"
			;;
			"-2") # The value (-2) means unknown
				EXIT_STRING="$EXIT_STRING$TRAY_NAME status is UNKNOWN!$SEPARATOR"
				TRAY_EXIT_CODE=3
			;;
			"0") # 0 means there is no paper left! This is our only critical value.
				# Determine paper size of current tray
				TRAY_FEED_DIMENSION=$(snmpwalk -v1 -Ovq -c $COMMUNITY $HOST_NAME 1.3.6.1.2.1.43.8.2.1.4.1.$1 2>/dev/null)
				TRAY_XFEED_DIMENSION=$(snmpwalk -v1 -Ovq -c $COMMUNITY $HOST_NAME 1.3.6.1.2.1.43.8.2.1.5.1.$1 2>/dev/null)
				TRAY_DIMENSION_UNITS=$(snmpwalk -v1 -Ovq -c $COMMUNITY $HOST_NAME 1.3.6.1.2.1.43.8.2.1.3.1.$1 2>/dev/null)

				if [ "$TRAY_FEED_DIMENSION" -lt 0 ] && [ "$TRAY_XFEED_DIMENSION" -lt 0 ]; then
					# If either dimension was negative, then we really don't know much about the dimension
					TRAY_DIMENSION_STRING="paper."
				else
			
					case "$TRAY_DIMENSION_UNITS" in
						"3") # convert ten thousandths of an inch to inches
						TRAY_FEED_DIMENSION=$(echo "scale=1;$TRAY_FEED_DIMENSION/10000" | bc)
						TRAY_XFEED_DIMENSION=$(echo "scale=1;$TRAY_XFEED_DIMENSION/10000" | bc)
						;;
						"4") # convert micrometers to inches, and get the int portion
						TRAY_FEED_DIMENSION=$(echo "scale=1;$TRAY_FEED_DIMENSION*0.0000393700787" | bc)
						TRAY_FEED_DIMENSION=$(echo "scale=1;$TRAY_FEED_DIMENSION+0.5" | bc)
						TRAY_FEED_DIMENSION=$(echo "scale=1;$TRAY_FEED_DIMENSION/1" | bc)

						TRAY_XFEED_DIMENSION=$(echo "scale=1;$TRAY_XFEED_DIMENSION*0.0000393700787" | bc)
						TRAY_XFEED_DIMENSION=$(echo "scale=1;$TRAY_XFEED_DIMENSION+0.5" | bc)
						TRAY_XFEED_DIMENSION=$(echo "scale=1;$TRAY_XFEED_DIMENSION/1" | bc)
						;;
					esac

					TRAY_DIMENSION_STRING="$TRAY_XFEED_DIMENSION x $TRAY_FEED_DIMENSION paper."
				fi

				EXIT_STRING="$EXIT_STRING$TRAY_NAME is at CRITICAL level - please refill with more $TRAY_DIMENSION_STRING$SEPARATOR"
				TRAY_EXIT_CODE=2
			;;
			*) # A positive number indicates how many pages are left. We'll calculate what % of capacity this is and determine status
				TRAY_MAX_CAPACITY=$(snmpwalk -v1 -Ovq -c $COMMUNITY $HOST_NAME 1.3.6.1.2.1.43.8.2.1.9.1.$1 2>/dev/null )
				let "TRAY_CAPACITY = $TRAY_CAPACITY * 100 / $TRAY_MAX_CAPACITY"
					
				if [ "$TRAY_CAPACITY" -gt "$CRITICAL" ]; then
					EXIT_STRING="$EXIT_STRING$TRAY_NAME is at $TRAY_CAPACITY%% - OK!$SEPARATOR"
				else
					if [ "$TRAY_CAPACITY" -le "$WARNING" ]; then
						# Determine paper size of current tray
						TRAY_FEED_DIMENSION=$(snmpwalk -v1 -Ovq -c $COMMUNITY $HOST_NAME 1.3.6.1.2.1.43.8.2.1.4.1.$1 2>/dev/null )
						TRAY_XFEED_DIMENSION=$(snmpwalk -v1 -Ovq -c $COMMUNITY $HOST_NAME 1.3.6.1.2.1.43.8.2.1.5.1.$1 2>/dev/null )
						TRAY_DIMENSION_UNITS=$(snmpwalk -v1 -Ovq -c $COMMUNITY $HOST_NAME 1.3.6.1.2.1.43.8.2.1.3.1.$1 2>/dev/null )
						if [ "$TRAY_FEED_DIMENSION" -lt 0 ] && [ "$TRAY_XFEED_DIMENSION" -lt 0 ]; then
							# If either dimension was negative, then we really don't know much about the dimension
							TRAY_DIMENSION_STRING="paper."
						else
							case "$TRAY_DIMENSION_UNITS" in
								"3") # convert ten thousandths of an inch to inches
								TRAY_FEED_DIMENSION=$(echo "scale=1;$TRAY_FEED_DIMENSION/10000" | bc)
								TRAY_XFEED_DIMENSION=$(echo "scale=1;$TRAY_XFEED_DIMENSION/10000" | bc)
								;;
								"4") # convert micrometers to inches, and get the int portion
								TRAY_FEED_DIMENSION=$(echo "scale=1;$TRAY_FEED_DIMENSION*0.0000393700787" | bc)
								TRAY_FEED_DIMENSION=$(echo "scale=1;$TRAY_FEED_DIMENSION+0.5" | bc)
								TRAY_FEED_DIMENSION=$(echo "scale=1;$TRAY_FEED_DIMENSION/1" | bc)

								TRAY_XFEED_DIMENSION=$(echo "scale=1;$TRAY_XFEED_DIMENSION*0.0000393700787" | bc)
								TRAY_XFEED_DIMENSION=$(echo "scale=1;$TRAY_XFEED_DIMENSION+0.5" | bc)
								TRAY_XFEED_DIMENSION=$(echo "scale=1;$TRAY_XFEED_DIMENSION/1" | bc)
								;;
							esac
									
							TRAY_DIMENSION_STRING="$TRAY_XFEED_DIMENSION x $TRAY_FEED_DIMENSION paper."
						fi
						
						if [ "$TRAY_CAPACITY" -le "$CRITICAL" ]; then
							# we have a critical: we already know the value is less than warning
							EXIT_STRING="$EXIT_STRING$TRAY_NAME is at $TRAY_CAPACITY%% - CRITICAL! Please refill with more $TRAY_DIMENSION_STRING$SEPARATOR"
							TRAY_EXIT_CODE=2
						else
							# we are only below warning, but not yet below critical
							EXIT_STRING="$EXIT_STRING$TRAY_NAME is at $TRAY_CAPACITY%% - WARNING! Please refill with more $TRAY_DIMENSION_STRING$SEPARATOR"
							if [ "$TRAY_EXIT_CODE" -lt 1 ]; then
								TRAY_EXIT_CODE=1
							fi
						fi
					fi
				fi
				
				PERFDAT="$PERFDAT $TRAY_NAME=$TRAY_CAPACITY;$WARNING;$CRITICAL;"
			;;
		esac
		
	fi

	return $TRAY_EXIT_CODE

}

#########################################################
##		check_paper_trays Function	       ##
#########################################################
# Determines which trays to check and passes each check	#
# off to check_one_tray.				#
#							#
# Global string variables are used for printing status 	#
# and perf data.					#
#########################################################

function check_paper_trays (){

	TRAYS_EXIT_CODE=0
	ALL_TRAYS=$(snmpwalk -v1 -On -c $COMMUNITY $HOST_NAME 1.3.6.1.2.1.43.8.2.1.10.1 2>/dev/null)
	CURRENT_TRAY_STATUS=0
	
	case "$1" in
		"TEST")
			echo "Trays you may monitor:"
			echo "$(echo "$ALL_TRAYS" | egrep -oe '[[:digit:]]+\ =' | cut -d " " -f1)"
			TRAYS_EXIT_CODE=3
		;;
		"ALL") # let's check all trays!
			for TRAY_ID in $(echo "$ALL_TRAYS" | egrep -oe '[[:digit:]]+\ =' | cut -d " " -f1)
			do
				check_one_tray "$TRAY_ID"
				CURRENT_TRAY_STATUS=$?
				
				if [ "$CURRENT_TRAY_STATUS" -gt "$TRAYS_EXIT_CODE" ]; then
					TRAYS_EXIT_CODE="$CURRENT_TRAY_STATUS"
				fi
			done
		;;
		*) 
			for TRAY_ID in $(echo "$1" | tr "$ARG_TOKEN" "\n")
			do
				check_one_tray "$TRAY_ID"
				CURRENT_TRAY_STATUS=$?
				
				if [ "$CURRENT_TRAY_STATUS" -gt "$TRAYS_EXIT_CODE" ]; then
					TRAYS_EXIT_CODE="$CURRENT_TRAY_STATUS"
				fi
			done
		;;
	esac
	
	return $TRAYS_EXIT_CODE
	
}

#########################################################
##			MAIN CODE		       ##
#########################################################

# Check that all required binaries for the script are available
# 	EXIT with an UNKNOWN status if not
binaries="snmpwalk snmpget bc egrep xxd"

for required_binary in $binaries; 
do
	which $required_binary > /dev/null
	if [ "$?" != '0' ];then
		printf "UNKNOWN: $APPNAME: No usable '$required_binary' binary in '$PATH'\n"
		exit 3
	fi
done

# Parse our options as passed, and make sure things are peachy
while getopts "C:H:c:w:x:S:hV" OPTION;
do
	case $OPTION in
		"C") # Assign community
			COMMUNITY="$OPTARG"
		;;
		"H") # Assign hostname
			HOST_NAME="$OPTARG"
		;;
		"c") # Assign CRITICAL threshold
			CRITICAL="$OPTARG"
		;;
		"w") # Assign WARNING threshold
			WARNING="$OPTARG"
		;;
		"x") # Assign check to perform
			CHECK=$(echo "$OPTARG" | cut -d " " -f1)
			PARAMETER=$(echo "$OPTARG" | cut -d " " -f2-)
		;;
		"S") # Assign separator
			SEPARATOR="$OPTARG"
		;;
		"h") # Print application help
			print_help
			exit $?
		;;
		"V") # Print application version
			printf "$APPNAME - version $VERSION\n"
			exit $EXIT_CODE
		;;
	esac
done

# Make sure all necessary arguments were given; EXIT with an UNKNOWN status if not
if [ -z "$COMMUNITY" ] || [ -z "$HOST_NAME" ];then
	# we need these parameters to continue
	EXIT_STRING="UNKNOWN: Hostname and/or Community variables have not been set!\n"
	EXIT_CODE=3
else
	ALL_MARKERS=$(snmpwalk -v1 -On -c $COMMUNITY $HOST_NAME 1.3.6.1.2.1.43.11.1.1.6.1 2>/dev/null)
	if [ $? -ne 0 ]; then
		#Check for server response - is SNMP even setup okay?
		EXIT_STRING="WARNING: No SNMP response from $HOST_NAME! Make sure host is up and SNMP is configured properly.\n"
		EXIT_CODE=1
	else
		STRING_TYPE=$(echo "$ALL_MARKERS" | tr -d "\n" | cut -d " " -f3)
		case "$CHECK" in
			"MESSAGES") 
				check_messages
				;;
			"MODEL") 
				check_model
				;;
			"CONSUM") 
				check_consumables "$PARAMETER"
				;;
			"CONSUMX") 
				check_exact_consumable "$PARAMETER"
				;;
			"TRAY") 
				check_paper_trays "$PARAMETER"
				;;
			"PAGECOUNT") 
				check_page_count
				;;
			"DEVICES") 
				check_device_status
				;;
			"STATUS") 
				check_printer_status
				;;
			"DISPLAY") 
				check_display
				;;
			*) # no parameters were passed, or a parameter was incorrect (wrong spelling, etc.)
				echo 'Invalid check specified by -x parameter.'
				echo ''
				print_help
				;;
		esac	

		EXIT_CODE=$?
	fi
fi

# If the program hasn't exited already, then a check was run okay and we can quit.
if [ "$PERFDAT" == "" ]; then
	printf "$EXIT_STRING\n"
else
	printf "$EXIT_STRING|$PERFDAT\n"
fi

exit $EXIT_CODE
