#!/bin/bash

plugindir=/usr/lib/nagios/plugins
sendscript=/usr/local/bin/send_nrdp.sh
nagiosurl=http://nagios.rely.nl/nrdp/
commandfile=/tmp/nrdp_send_q

rm $commandfile

while read inputline
do
	host="$(echo $inputline | cut -d, -f1)"
	service="$(echo $inputline | cut -d, -f2)"
	plugin="$(echo $inputline | cut -d, -f 3-)"
	echo /usr/local/bin/nrdp_wrapper.sh -b $sendscript -H $host -S $service -C \"$plugindir/$plugin\" -N $nagiosurl >> $commandfile
done < $1

sh $commandfile
exit 0

