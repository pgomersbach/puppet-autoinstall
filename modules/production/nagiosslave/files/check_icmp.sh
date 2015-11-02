output="`ping -c 1 $1 2>&1`"
returncode=$?

if [[ $returncode != 0 ]]; then
    echo "NOK - $1"
    exit 1
else
    echo "OK - $1"
    exit 0
fi
