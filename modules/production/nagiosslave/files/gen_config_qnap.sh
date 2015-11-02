#!/bin/sh

# Run plugins from default file from ftp server, prints results of checks returning, ok, warn or err to stdout in configfile format
# Needs nagios-plugins,

process_services ()
{
        host="$(echo $@ | cut -d, -f1)"
	pingcommand="$plugindir/check_icmp.sh $host"
	pingresult=`eval $pingcommand 2>&1`
	if [[ "$?" == 0 || "$?" == 1 ]]; then
        	plugin="$plugindir/$(echo "$@" | cut -d, -f 3-)"
        	args="$(echo $plugin | cut -d\  -f 2-)"
        	plugin="$(echo $plugin | cut -d\  -f1)"
        	output=`eval $plugin $args 2>&1`
        	returncode=$?
		if [[ "$returncode" == 0 ]]; then
			$echocommand $@
			$echocommand $@ >> /tmp/$lowhost.conf
		fi
	fi
}


# Start of main script

# get hostname and convert to lower case
thishost=$(hostname -f)
lowhost="$(tr [A-Z] [a-z] <<< "$thishost")"

# Remove old config
rm -f /tmp/nas-default.conf
rm -f /tmp/$lowhost.conf
# Get default configuration
wget -q --no-passive-ftp ftp://www.gofilex.nl/nas-default.conf -O /tmp/nas-default.conf 2>&1

# Change default name to hostname
sed -i "s/default/$lowhost/g" /tmp/nas-default.conf

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

while read inputline
do
        process_services $inputline
done < /tmp/nas-default.conf

exit 0

