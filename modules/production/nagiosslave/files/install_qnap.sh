#!/bin/sh

check_configfile ()
{
# Check configfile syntax
E_BADCONF=66
E_NOCONF=67

if [ -e $1 ]
then
        echo ""
else
        echo "Configuration file $1 not readable"
        exit $E_NOCONF
fi
## end of function
}


# install nagios plugins
# ipkg list | grep -i "nagios-plugins"
ipkg install nagios-plugins net-snmp wput wget

# get send scripts
wget http://puppet-autoinstall.googlecode.com/git/modules/production/nagiosslave/files/send_nrdp.php -O /usr/local/bin/send_nrdp.php
wget http://puppet-autoinstall.googlecode.com/git/modules/production/nagiosslave/files/run_pluginsphp.sh -O /usr/local/bin/run_pluginsphp.sh 

# change permissons
chmod +x /usr/local/bin/run_pluginsphp.sh  /usr/local/bin/send_nrdp.php

wget --no-passive-ftp ftp://www.gofilex.nl/run_plugins.conf  -O /etc/run_plugins.conf

# read config file
check_configfile "/etc/run_plugins.conf"
. "/etc/run_plugins.conf"            # read configuration file

if [ -d "/share/MD0_DATA/.qpkg/Optware/libexec" ]; then
        echocommand="echo -e"   # on a qnap
        plugindir=/share/MD0_DATA/.qpkg/Optware/libexec
else
        if [ -d "/share/HDA_DATA/.qpkg/Optware/libexec" ]; then
                echocommand="echo -e"   # on a qnap
                plugindir=/share/HDA_DATA/.qpkg/Optware/libexec
        else
                echocommand="echo"      # no qnap
        fi
fi


# get extra checks in plugin directory
wget http://puppet-autoinstall.googlecode.com/git/modules/production/nagiosslave/files/check_qnap_serial.sh -O $plugindir/check_qnap_serial.sh
wget http://puppet-autoinstall.googlecode.com/git/modules/production/nagiosslave/files/check_qnap_disktemp.sh -O $plugindir/check_qnap_disktemp.sh
wget http://puppet-autoinstall.googlecode.com/git/modules/production/nagiosslave/files/check_icmp.sh -O $plugindir/check_icmp.sh
wget http://puppet-autoinstall.googlecode.com/git/modules/production/nagiosslave/files/check_qnap_interface.sh -O $plugindir/check_qnap_interface.sh
wget http://puppet-autoinstall.googlecode.com/git/modules/production/nagiosslave/files/check_projector_serial.sh -O $plugindir/check_projector_serial.sh
wget http://puppet-autoinstall.googlecode.com/git/modules/production/nagiosslave/files/check_outsideip.sh -O $plugindir/check_outsideip.sh
wget http://puppet-autoinstall.googlecode.com/git/modules/production/nagiosslave/files/check_qnap_smart.sh -O $plugindir/check_qnap_smart.sh
wget http://puppet-autoinstall.googlecode.com/git/modules/production/nagiosslave/files/scan_servers_qnap.sh -O $plugindir/scan_servers_qnap.sh
wget http://puppet-autoinstall.googlecode.com/git/modules/production/nagiosslave/files/gen_config_qnap.sh -O $plugindir/gen_config_qnap.sh

# change permissons
chmod +x  $plugindir/*.sh

# get hostname and convert to lower case
thishost=$(hostname -f)
lowhost="$(tr [A-Z] [a-z] <<< "$thishost")"

# check if we have a host file containing the word "Scanned"
grep "Scanned" /etc/hosts
if [ $? == 1 ] ; then
	# get hosts file based on hostname
	wget --no-passive-ftp ftp://www.gofilex.nl/$lowhost.hosts -O /etc/hosts.conf
	if [ -s /etc/hosts.conf ] ; then
	        echo "filename exists and is > 0 bytes"
       		cp /etc/hosts.conf /etc/hosts
	else
        	echo "filename does not exist or is zero length"
		$plugindir/scan_servers_qnap.sh > /etc/hosts
	fi
fi

# get configuration file based on hostname
wget --no-passive-ftp ftp://www.gofilex.nl/$lowhost.conf -O /etc/nagiosslave.conf
if [ $? != 0 ] ; then
        $plugindir/gen_config_qnap.sh > /etc/nagiosslave.conf
fi
check_configfile "/etc/nagiosslave.conf"

# modify cron
tmpfile=/tmp/crontab.tmp

# read crontab and remove custom entries (usually not there since after a reboot
# QNAP restores to default crontab:
crontab -l | grep -vi "run_pluginsphp" > $tmpfile

# add custom entries to crontab
# randomize cron entry to spread load
#### Old entry every 5 minutes
# CRONSTART=$(expr $RANDOM % 5)
# echo -n "$(($CRONSTART)),$(($CRONSTART + 5)),$(($CRONSTART + 10)),$(($CRONSTART + 15)),$(($CRONSTART + 20))," >> $tmpfile
# echo -n "$(($CRONSTART + 25)),$(($CRONSTART + 30)),$(($CRONSTART + 35)),$(($CRONSTART + 40))," >> $tmpfile
# echo "$(($CRONSTART + 45)),$(($CRONSTART + 50)),$(($CRONSTART + 55)) * * * * /usr/local/bin/run_pluginsphp.sh /etc/run_plugins.conf /etc/nagiosslave.conf"  >> $tmpfile

#### New entry, every 20 minutes
CRONSTART=$(expr $RANDOM % 20)
echo "$(($CRONSTART)),$(($CRONSTART + 20)),$(($CRONSTART + 40)) * * * * /usr/local/bin/run_pluginsphp.sh /etc/run_plugins.conf /etc/nagiosslave.conf"  >> $tmpfile


# kill crond
/usr/bin/killall crond

#load crontab from file
crontab $tmpfile

# restart crontab
/etc/init.d/crond.sh restart

# remove temporary file
rm $tmpfile
