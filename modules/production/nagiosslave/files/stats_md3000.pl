#!/usr/bin/perl -w

use strict;

#Change this to fit your installation
my $SMcli="/usr/bin/SMcli";
my ($x,$host1,$host2,$host,$vm,$arg,$find_only,$cmd);
for $x ( 0 .. $#ARGV ){

  $arg = $ARGV[$x];

  if ( $arg eq "-H" ){
    $find_only = 1;
    $x++;
    $host1 = ${ARGV[$x]};
    $host2 = ${ARGV[$x+1]};
    next;
    }

  if ( $arg eq "-v" ){
    $x++;
    $vm = ${ARGV[$x]};
    next;
    }
  }

#Execute SMcli command
if(!$vm)
{
  $vm = "STORAGE ARRAY TOTALS";
  $cmd = "$SMcli $host1 $host2 -S -quick -c \"show allVirtualDisks performanceStats;\"";
} else {
  $cmd = "$SMcli $host1 $host2 -S -quick -c \"show virtualDisk [\\\"$vm\\\"] performanceStats;\"";
}

if(!open(PIPE, "$cmd|"))
{
	die("Could not execute $cmd");
}

my $globalstatus = "";
my $extendedstatus = "";
my $vmdisk = "";
my $totalio = "";
my $readpercentage = "";
my $cachehitpercentage = "";
my $currentkbpersecond = "";
my $maximumkbpersecond = "";
my $currentiopersecond = "";
my $maximumiopersecond = "";
while(my $line = <PIPE>)
{
        chomp($line);
        if($line =~ /$vm/)
        {
                $globalstatus = $line;
        	($vmdisk, $totalio, $readpercentage, $cachehitpercentage, $currentkbpersecond, $maximumkbpersecond, $currentiopersecond, $maximumiopersecond) = split (",", $line);
        	$totalio =~ s/\"//g;
        	$readpercentage =~ s/\"//g;
        	$cachehitpercentage =~ s/\"//g;
        	$currentkbpersecond =~ s/\"//g;
        	$maximumkbpersecond =~ s/\"//g;
        	$currentiopersecond =~ s/\"//g;
        	$maximumiopersecond =~ s/\"//g;
	
	        print "$vmdisk OK - $currentkbpersecond KBs, $currentiopersecond IOs | totalio=$totalio readpercentage=$readpercentage cachehitpercentage=$cachehitpercentage currentkbpersecond=$currentkbpersecond maximumkbpersecond=$maximumkbpersecond currentiopersecond=$currentiopersecond maximumiopersecond=$maximumiopersecond\n";
        }
        else
        {
                $extendedstatus .= $line;
        }
}


close(PIPE);
