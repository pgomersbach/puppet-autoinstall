#!/bin/sh
output="`wget -qO- http://www.icanhazip.com 2>&1`"
returncode=$?

if [ $returncode != 0 ]; then
    echo "OK - Could not determine outside address"
    exit 0
else
    geo="`curl --silent ipinfo.io/$output | grep loc | cut -f 2 -d : | cut -f 2 -d '\"' 2>&1`"
    echo "OK - Outside IP address: $output, Geoip: $geo"
    exit 0
fi
