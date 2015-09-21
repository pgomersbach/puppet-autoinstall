#!/usr/bin/perl

#    Copyright (C) 2004 Altinity Limited
#    E: info@altinity.com    W: http://www.altinity.com/
#    Modified by pierre.gremaud@bluewin.ch
#    Modified by Oliver Skibbe oliver.skibbe at mdkn.de
#    
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version.
#    
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.    See the
#    GNU General Public License for more details.
#    
#    You should have received a copy of the GNU General Public License
#    along with this program; if not, write to the Free Software
#    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA    02111-1307    USA
# 
# 2013-07-08: Oliver Skibbe oliver.skibbe (at) mdkn.de
#	- warn/crit values defined per variable
# 	- get watt hour if oid exists (Smart UPS 2200)
# 	- calculate remaining time in minutes on battery (bit ugly, but seems working)
#		critical if below $remaining_time_crit value
# 	- changed return string to add CRIT/WARN to corresponding failed value
#		Before: CRIT - Smart-UPS RT 10000 XL - BATTERY CAPACITY 100% - STATUS NORMAL - OUTPUT LOAD 31% - TEMPERATURE 23 C 
#		After: CRIT - Smart-UPS RT 10000 XL - CRIT BATTERY CAPACITY 50% - STATUS NORMAL - OUTPUT LOAD 31% - TEMPERATURE 23 C
#	- Added multiline output for firmware,manufacture date and serial number

use Net::SNMP;
use Getopt::Std;
# DEBUGGING PURPOSE 
use Data::Dumper;

$script    = "check_ups_apc.pl";
$script_version = "1.1";

$metric = 1;

$version = "1";			# SNMP version
$timeout = 2;			# SNMP query timeout
# $warning = 100;			
# $critical = 150;
$status = 0;
$returnstring = "";
$perfdata = "";

$community = "public"; 		# Default community string

$oid_sysDescr = ".1.3.6.1.2.1.1.1.0";
$oid_serial_number = ".1.3.6.1.4.1.318.1.1.1.1.2.3.0";
$oid_firmware = ".1.3.6.1.4.1.318.1.1.1.1.2.1.0";
$oid_manufacture_date = ".1.3.6.1.4.1.318.1.1.1.1.2.2.0";
$oid_upstype = ".1.3.6.1.4.1.318.1.1.1.1.1.1.0";
$oid_battery_capacity = ".1.3.6.1.4.1.318.1.1.1.2.2.1.0";
$oid_output_status = ".1.3.6.1.4.1.318.1.1.1.4.1.1.0";
$oid_output_current = ".1.3.6.1.4.1.318.1.1.1.4.2.4.0";
$oid_output_load = ".1.3.6.1.4.1.318.1.1.1.4.2.3.0";
$oid_temperature = ".1.3.6.1.4.1.318.1.1.1.2.2.2.0";
$oid_remaining_time = ".1.3.6.1.4.1.318.1.1.1.2.2.3.0";
# optional, Smart-UPS 2200 support this
$oid_current_load_wh = ".1.3.6.1.4.1.318.1.1.1.4.3.6.0";

$oid_battery_replacment = ".1.3.6.1.4.1.318.1.1.1.2.2.4.0";

$upstype = "";
$battery_capacity = 0;
$output_status = 0;
$output_current = 0;
$output_load = 0;
$temperature = 0;

# crit / warn values
$remaining_time_crit = 5;
$output_load_crit = 80;
$output_load_warn = 70;
$temperature_crit = 38;
$temperature_warn = 35;
$battery_capacity_crit = 35;
$battery_capacity_warn = 65;

# Do we have enough information?
if (@ARGV < 1) {
     print "Too few arguments\n";
     usage();
}

getopts("h:H:C:w:c:");
if ($opt_h){
    usage();
    exit(0);
}
if ($opt_H){
    $hostname = $opt_H;
}
else {
    print "No hostname specified\n";
    usage();
}
if ($opt_C){
    $community = $opt_C;
}
else {
}



# Create the SNMP session
my ($s, $e) = Net::SNMP->session(
     -community  =>  $community,
     -hostname   =>  $hostname,
     -version    =>  $version,
     -timeout    =>  $timeout,
);

main();

# Close the session
$s->close();

if ($status == 0){
    print "OK - $returnstring|$perfdata\n";
}
elsif ($status == 1){
    print "WARNING - $returnstring|$perfdata\n";
}
elsif ($status == 2){
    print "CRITICAL - $returnstring|$perfdata\n";
}
else{
    print "No response from SNMP agent.\n";
}
 
exit $status;


####################################################################
# This is where we gather data via SNMP and return results         #
####################################################################

sub main {

    #######################################################
 
    if (!defined($s->get_request($oid_upstype))) {
        if (!defined($s->get_request($oid_sysDescr))) {
            $returnstring = "SNMP agent not responding";
            $status = 1;
            return 1;
        }
        else {
            $returnstring = "SNMP OID does not exist";
            $status = 1;
            return 1;
        }
    }
    foreach ($s->var_bind_names()) {
         $upstype = $s->var_bind_list()->{$_};
    }
    #######################################################
 
    if (!defined($s->get_request($oid_battery_capacity))) {
        if (!defined($s->get_request($oid_sysDescr))) {
            $returnstring = "SNMP agent not responding";
            $status = 1;
            return 1;
        }
        else {
            $returnstring = "SNMP OID does not exist";
            $status = 1;
            return 1;
        }
    }
    foreach ($s->var_bind_names()) {
         $battery_capacity = $s->var_bind_list()->{$_};
    }
    #######################################################
 
    if (!defined($s->get_request($oid_output_status))) {
        if (!defined($s->get_request($oid_sysDescr))) {
            $returnstring = "SNMP agent not responding";
            $status = 1;
            return 1;
        }
        else {
            $returnstring = "SNMP OID does not exist";
            $status = 1;
            return 1;
        }
    }
    foreach ($s->var_bind_names()) {
         $output_status = $s->var_bind_list()->{$_};
    }
    #######################################################
 
    if (!defined($s->get_request($oid_output_current))) {
        if (!defined($s->get_request($oid_sysDescr))) {
            $returnstring = "SNMP agent not responding";
            $status = 1;
            return 1;
        }
        else {
            $returnstring = "SNMP OID does not exist";
            $status = 1;
            return 1;
        }
    }
    foreach ($s->var_bind_names()) {
        $output_current = $s->var_bind_list()->{$_};
    }
    #######################################################

    # special.. added for SMART-UPS 2200 
    if (defined($s->get_request($oid_current_load_wh))) {
	     	foreach ($s->var_bind_names()) {
        		$output_current_load_wh = $s->var_bind_list()->{$_};
		}
    }

	# some useful stuff
    if (defined($s->get_request($oid_firmware))) {
		foreach ($s->var_bind_names()) {
                	$firmware = $s->var_bind_list()->{$_};
        	}
    }
    if ( defined (  $s->get_request($oid_serial_number))) {
	        foreach ($s->var_bind_names()) {
                	$serial_number = $s->var_bind_list()->{$_};
	        }
    }
    if ( defined (  $s->get_request($oid_manufacture_date))) {
	        foreach ($s->var_bind_names()) {
        	        $manufacture_date = $s->var_bind_list()->{$_};
	        }
    }

    #######################################################

    if (!defined($s->get_request($oid_output_load))) {
        if (!defined($s->get_request($oid_output_load))) {
            $returnstring = "SNMP agent not responding";
            $status = 1;
            return 1;
        }
        else {
            $returnstring = "SNMP OID does not exist";
            $status = 1;
            return 1;
        }
    }
    foreach ($s->var_bind_names()) {
         $output_load = $s->var_bind_list()->{$_};
    }
    #######################################################
    
    if (!defined($s->get_request($oid_battery_replacment))) {
        if (!defined($s->get_request($oid_battery_replacement))) {
            $returnstring = "SNMP agent not responding";
            $status = 1;
            return 1;
        }
        else {
            $returnstring = "SNMP OID does not exist";
            $status = 1;
            return 1;
        }
    }
    foreach ($s->var_bind_names()) {
         $battery_replacement = $s->var_bind_list()->{$_};
    }

    #######################################################

    if (!defined($s->get_request($oid_remaining_time))) {
        if (!defined($s->get_request($oid_sysDescr))) {
            $returnstring = "SNMP agent not responding";
            $status = 1;
            return 1;
        }
        else {
            $returnstring = "SNMP OID does not exist";
            $status = 1;
            return 1;
        }
    }
    foreach ($s->var_bind_names()) {
        $remaining_time = $s->var_bind_list()->{$_}; # returns (days),(hours),(minutes),seconds
    }

    #######################################################
  
    if (!defined($s->get_request($oid_temperature))) {
        if (!defined($s->get_request($oid_sysDescr))) {
            $returnstring = "SNMP agent not responding";
            $status = 1;
            return 1;
        }
        else {
            $returnstring = "SNMP OID does not exist";
            $status = 1;
            return 1;
        }
    }
     foreach ($s->var_bind_names()) {
         $temperature = $s->var_bind_list()->{$_};
    }
    #######################################################
     
    $returnstring = "";
    $status = 0;
    $perfdata = "";

    if (defined($oid_upstype)) {
        $returnstring = "$upstype - ";
    }

    if ( $battery_replacement == 2 ) {
        $returnstring = $returnstring . "CRIT BATTERY REPLACEMENT NEEDED - ";
        $status = 2;
    }
    elsif ($battery_capacity < $battery_capacity_crit) {
        $returnstring = $returnstring . "CRIT BATTERY CAPACITY $battery_capacity% - ";
        $status = 2;
    }
    elsif ($battery_capacity < $battery_capacity_warn ) {
        $returnstring = $returnstring . "WARN BATTERY CAPACITY $battery_capacity% - ";
        $status = 1 if ( $status != 2 );
    }
    elsif ($battery_capacity <= 100) {
        $returnstring = $returnstring . "BATTERY CAPACITY $battery_capacity% - ";
    }
    else {
        $returnstring = $returnstring . "UNKNOWN BATTERY CAPACITY! - ";
        $status = 3 if ( ( $status != 2 ) && ( $status != 1 ) );
    }

    if ($output_status eq "2"){
        $returnstring = $returnstring . "STATUS NORMAL - ";
    }
    elsif ($output_status eq "3"){
        $returnstring = $returnstring . "UPS RUNNING ON BATTERY! - ";
        $status = 1 if ( $status != 2 );
    }
    elsif ($output_status eq "9"){
        $returnstring = $returnstring . "UPS RUNNING ON BYPASS! - ";
        $status = 1 if ( $status != 2 );
    }
    elsif ($output_status eq "10"){
        $returnstring = $returnstring . "HARDWARE FAILURE UPS RUNNING ON BYPASS! - ";
        $status = 1 if ( $status != 2 );
    }
    elsif ($output_status eq "6"){
        $returnstring = $returnstring . "UPS RUNNING ON BYPASS! - ";
        $status = 1 if ( $status != 2 );
    }
    else {
        $returnstring = $returnstring . "UNKNOWN OUTPUT STATUS! - ";
        $status = 3 if ( ( $status != 2 ) && ( $status != 1 ) );
    }


    if ($output_load > $output_load_crit) {
        $returnstring = $returnstring . "CRIT OUTPUT LOAD $output_load% - ";
        $perfdata = $perfdata . "'load'=$output_load ";
        $status = 2;
    }
    elsif ($output_load > $output_load_warn) {
        $returnstring = $returnstring . "WARN OUTPUT LOAD $output_load% - ";
        $perfdata = $perfdata . "'load'=$output_load ";
        $status = 1 if ( $status != 2 );
    }
    elsif ($output_load >= 0) {
        $returnstring = $returnstring . "OUTPUT LOAD $output_load% - ";
        $perfdata = $perfdata . "'load'=$output_load ";
    }
    else {
        $returnstring = $returnstring . "UNKNOWN OUTPUT LOAD! - ";
        $perfdata = $perfdata . "'load'=NAN ";
        $status = 3 if ( ( $status != 2 ) && ( $status != 1 ) );
    }

    if ($temperature > $temperature_crit) {
        $returnstring = $returnstring . "CRIT TEMPERATURE $temperature C - ";
        $perfdata = $perfdata . "'temp'=$temperature ";
        $status = 2;
    }
    elsif ($temperature > $temperature_warn) {
        $returnstring = $returnstring . "WARN TEMPERATURE $temperature C - ";
        $perfdata = $perfdata . "'temp'=$temperature ";
        $status = 1 if ( $status != 2 );
    }
    elsif ($temperature >= 0) {
        $returnstring = $returnstring . "TEMPERATURE $temperature C - ";
        $perfdata = $perfdata . "'temp'=$temperature ";
    }
    else {
        $returnstring = $returnstring . "UNKNOWN TEMPERATURE! - ";
        $perfdata = $perfdata . "'temp'=NAN ";
        $status = 3 if ( ( $status != 2 ) && ( $status != 1 ) );
    }

    # remaining time
    if ( defined ( $remaining_time ) ) {
	# convert time to minutes
	my @a = split(/ /,$remaining_time);
	my $timeUnit = @a[1];
	my $minutes = 0;

	if ( $timeUnit =~ /hour/ ) {
		# hours returned
		my @minutesArray = split(/:/,@a[2]);
		$minutes = @a[0] * 60;
		$minutes = $minutes + @minutesArray[0];
	} elsif ( $timeUnit =~ /minute/ ) {
		# minutes returned
		$minutes = @a[0];
	} else {
		# seconds returned?
		$minutes = 0;
	}

	if ( $minutes <= $remaining_time_crit ) {
		$returnstring = $returnstring . "CRIT $minutes MINUTES REMAINING";
	       	$status = 2;
	} else {
		$returnstring = $returnstring . "$minutes MINUTES REMAINING";
	}

	$perfdata = $perfdata . "'remaining_minutes'=$minutes";
    }

    # load in watthour
    if ( defined ($output_current_load_wh) ) {	
	    	$perfdata = $perfdata . " 'loadwh'=$output_current_load_wh";
   		$returnstring = $returnstring . " - CURRENT LOAD $output_current_load_wh Wh";
    }

    $returnstring = $returnstring . "\nFIRMWARE: $firmware - MANUFACTURE DATE: $manufacture_date - SERIAL: $serial_number";
}

####################################################################
# help and usage information                                       #
####################################################################

sub usage {
    print << "USAGE";
-----------------------------------------------------------------	 
$script v$script_version

Monitors APC SmartUPS via AP9617 SNMP management card.

Usage: $script -H <hostname> -C <community> [...]

Options: -H 	Hostname or IP address
         -C 	Community (default is public)
	 
-----------------------------------------------------------------	 
Copyright 2004 Altinity Limited	 
	 
This program is free software; you can redistribute it or modify
it under the terms of the GNU General Public License
-----------------------------------------------------------------

USAGE
     exit 1;
}



