#!/bin/sh
#
# This is a generic nrdp wrapper to allow you to make any service check into a 
# passive service check without the need for writing wrappers for every
# check since that is a waste of time and effort. You can put everything
# you need on one line in order to submit a passive service check for Nagios

version=0.6

NAGIOS_SERVER=""
SEND_NRDP=""
TOKEN="rdr7c5np79sn"

usage(){
    echo "usage: ${0##*/} -H "'$HOSTNAME$'" -S "'$SERVICENAME$'" -C '/path/to/plugin/check_stuff -arg1 -arg2 ... -argN' [ -N <nagios.server.ip.address> -b /path/to/send_nrdp ]"
    echo 
    echo 'All of the following options are necessary unless stated otherwise'
    echo
    echo '-H $HOSTNAME$              The Host name of the server being checked by the'
    echo '                           plugin. It should be written exactly as it appears in'
    echo '                           the Nagios config/interface.'
    echo '-S $SERVICENAME$           The name of the service that is being checked by the'
    echo '                           plugin. It should be written exactly as it appears'
    echo '                           in the Nagios config/interface.'
    echo '-C COMMAND                 The command line to run the plugin (should be quoted)'
    echo '                           BE VERY CAREFUL WITH THIS. IT WILL EXECUTE USING SHELL'
    echo '-N IPADDRESS               The IP address of the nagios/nrdp server to send the'
    echo '                           result of the plugin to. This should be an IP instead'
    echo '                           of a DNS name. If you use a DNS name here and your'
    echo '                           dns service breaks, then all your passive checks will'
    echo '                           fail as they won'"'"'t find the nrdp server.'
    echo '-b /path/to/send_nrdp      The path to the send_nrdp binary. Optional. Only'
    echo '                           necessary if send_nrdp is not in your default PATH.' 
    echo '-e                         exit with the return code of the plugin rather than'
    echo '                           the return code of the sending to the NRDP daemon'
    echo '-q                         quiet mode. Do not show any output'
    echo '-V --version               Show version and exit'
    echo '-h --help                  Show this help'
    echo
    exit 3
}


die(){
    echo "$@"
    exit 3
}

if [ $# -eq 0 ]; then
    usage
fi


until [ -z "$1" ]
    do
    case "$1" in
        -h|--help)  usage
                    ;;
               -H)  host="$2"
                    shift
                    ;;
               -S)  service="$2"
                    shift
                    ;;
               -N)  nagios_server="$2"
                    shift
                    ;;
               -C)  cmd="$2"
                    shift
                    ;;
               -b)  send_nrdp="$2"
                    shift
                    ;;
               -e)  return_plugin_code=true
                    ;;
               -q)  quiet_mode=true
                    ;;
     -V|--version)  version_check=true
                    ;;
                *)  usage
                    ;;
    esac
    shift
done



if [ -z "$host" ]; then
    die "You must supply a Host name exactly as it appears in Nagios"
elif [ -z "$service" ]; then
    die "You must supply a Service name exactly as it appears in Nagios"
elif [ -z "$cmd" ]; then
    die "You must supply a command to execute"
fi

if [ -z "$nagios_server" ]; then
    if [ -n "$NAGIOS_SERVER" ]; then
        nagios_server="$NAGIOS_SERVER"
    else
        die "You must supply an address for the nagios server"
    fi
fi

if [ -z "$send_nrdp" ]; then
    if [ -n "$SEND_NRDP" ]; then
        send_nrdp="$SEND_NRDP"
    else
        # assume send_nrdp is in the PATH
        send_nrdp="send_nrdp"
    fi
fi

# Small safety check, this won't stop a kid.
# Might help a careless person though (yeah right)
#dangerous_commands="rm rmdir dd del mv cp halt shutdown reboot init telinit kill killall pkill"
#for x in $cmd; do
#    for y in $dangerous_commands; do
#    	if [ "$x" == "$y" ]; then
#        	echo "DANGER: the $y command was found in the string given to execute under nrdp_wrapper, aborting..."
#        	exit 3
#    	fi
#    done
#done

output="`$cmd 2>&1`"
result=$?
[ -z "$quiet_mode" ] && echo "$output"
output="`echo $output | sed 's/%/%%/g'`"

send_output=`printf "$host\t$service\t$result\t$output\n" | $send_nrdp -u $nagios_server -t $TOKEN 2>&1`
send_result=$?
[ -z "$quiet_mode" ] && echo "Sending to NRDP daemon: $send_output"

if [ -n "$return_plugin_code" ]; then
    exit "$result"
else
    exit "$send_result"
fi

