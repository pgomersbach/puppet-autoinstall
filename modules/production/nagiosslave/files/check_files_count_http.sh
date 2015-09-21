#!/bin/sh

if [ "$#" -ne 3 ]; then
  echo "Error: Too few parameters." >&2
  echo "Usage: $0 HOST PORT COUNT" >&2
  exit 3
fi

RESPONSE=`echo -n | nc $1 $2`
if [ "$?" -ne 0 ]; then
  echo "Error: Connecting host $1 on port $2." >&2
  exit 3
fi


if [ "$RESPONSE" -gt "$3" ]
then
	echo "CRITICAL - Server response is greater than $3 files | files=$RESPONSE"
	exit 2
else
	echo "OK - Server response is less or equal to $3 files | files=$RESPONSE"
	exit 0
fi

