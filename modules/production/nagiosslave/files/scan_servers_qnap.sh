#!/bin/sh

# scan_servers for qnap, detects type of video server (Dolby, Doremi), output format as /etc/hosts
# optoinal a interfacename as parameter
# Sensor program
SENSORPROG=/opt/bin/snmpget

# Oid to monitor
doremi_oid=enterprises.24391.1.3.6.0
dolby_oid=1.3.6.1.4.1.6729.2.1.1.4.1.1.1.0
community=public

ipkg -V 0 install nmap lua
TIME=$(date +"%d-%m-%Y %T")

# get hostname and convert to lower case
thishost=$(hostname)
lowhost="$(tr [A-Z] [a-z] <<< "$thishost")"

if [[ $1 ]]; then
        interface=$1
else
        interface=eth0
fi

address=`ip -f inet addr | grep "global $interface" | cut -d\  -f6 2>&1`
addr=`ip -f inet addr | grep "global $interface" | cut -d\  -f6 | cut -d/ -f1 2>&1`

if [[ "$addr" ==  "" ]] ; then
        echo "Wrong interface $interface"
        exit 1
fi

uniqhosts=`nmap --open -sU -p 161 -oG - $address|grep "open/udp"|cut -d \  -f 2 2>&1`
echo -e "127.0.0.1\tlocalhost\tlocalhost"
echo -e "$addr\t$thishost\tdatakluis1.$lowhost.nl\n"
echo "# Scanned hosts on interface $interface $address, Scanned on $TIME"
for host in $uniqhosts;
do
        TYPE="Doremi"
        SERIAL=`${SENSORPROG} -v2c -On -c $community $host $doremi_oid  2>/dev/null | cut -d " " -f4-`
        if [[ "$SERIAL" ]]; then
                if [[ "$SERIAL" =~ .*Object.* ]]; then
                        TYPE="Dolby"
                        SERIAL=`${SENSORPROG} -v2c -On -c $community $host $dolby_oid  2>/dev/null | cut -d " " -f4-`
                        if [[ "$SERIAL" =~ .*Object.* ]]; then
                                TYPE="Cannot determine type of server"
                        fi
                fi
        else
                TYPE="Host is not respnding"
        fi
        if [[ $TYPE == "Dolby" || $TYPE == "Doremi" ]]; then
                server=$((server+1))
                echo -e "$host\tserver$server.$lowhost.nl # $TYPE"
        fi

done

