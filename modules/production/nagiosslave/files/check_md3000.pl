#!/usr/bin/perl -w

#
#    Check status on Dells MD3000i iSCSI-SAN
#    You need SMcli installed to use this check. It's part of
#    Dells MDSM package.
#
#    Version 1.1
#
#
#    Copyright (C) 2009 Pontus Fuchs
#    pontus.fuchs at tactel.se
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


use strict;
use Getopt::Std;

#Change this to fit your installation
my $SMcli="/opt/dell/mdstoragemanager/client/SMcli";

my %options=();
getopts("H:",\%options);

if(!defined $options{H})
{
	die("Usage: check_md3000i.pl -H host");
}

my $host = $options{H};

#Execute SMcli command
my $cmd = "$SMcli $host -S -quick -c \"show storageArray healthStatus;\";";
if(!open(PIPE, "$cmd|"))
{
	die("Could not execute $cmd");
}

#Parse SMCli output. SMCli usually returns one line like this:
#
#Storage array health status = optimal.
#
#But it can also be more verbose like this:
#
#The RAID controller module clocks in the storage array are out of synchronization with the storage management station.
#
#RAID Controller Module in Slot 0: Mon Aug 31 09:48:28 CEST 2009 
#RAID Controller Module in Slot 1: Mon Aug 31 09:48:32 CEST 2009
#Storage Management Station: Mon Aug 31 09:40:14 CEST 2009
#
#Storage array health status = optimal.

my $globalstatus = "";
my $extendedstatus = "";
while(my $line = <PIPE>)
{
	chomp($line);
	if($line =~ /Storage array health status/)
	{
		$globalstatus = $line;
	}
	else
	{
		$extendedstatus .= $line;
	}
}


close(PIPE);
my $retcode = $?;

my $info = "";
my $ret = 0;

if($extendedstatus ne "")
{
	if(length($extendedstatus) > 60)
	{
		$extendedstatus = substr($extendedstatus, 0, 60) . "...";
	}
	$extendedstatus = " (" . $extendedstatus . ")";
}


if($retcode ne 0 || $globalstatus !~ "optimal")
{
	$ret = 2;
	$info = "ERROR - $globalstatus (SMcli return code " . ($retcode>>8) . ")". "$extendedstatus\n"; 
}
else
{
	$ret = 0;
	$info = "OK - " . $globalstatus . "$extendedstatus\n"; 
}

print $info;
exit $ret;
