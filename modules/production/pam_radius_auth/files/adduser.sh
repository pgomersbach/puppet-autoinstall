#!/bin/bash
# Script to add a user to Linux system
# -------------------------------------------------------------------------
if [ $(id -u) -eq 0 ]; then
	egrep "^$1" /etc/passwd >/dev/null
	if [ $? -eq 0 ]; then
		echo "$username exists!"
		exit 1
	else
		useradd -m $1
		[ $? -eq 0 ] && echo "User has been added to system!" || echo "Failed to add a user!"
	fi
else
	echo "Only root may add a user to the system"
	exit 2
fi
