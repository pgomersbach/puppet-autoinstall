#!/bin/bash
. /etc/run_plugins.conf
/usr/bin/printf "%s\t%s\t%s\t%s" "$1" "$2" "$3" "$4" | /usr/bin/php /usr/local/bin/send_nrdp.php --url=$nagiosurl --token=$token --usestdin
