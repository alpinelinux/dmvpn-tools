#!/bin/sh -e

sh ./dependencies.sh

while read cmd; do
	if [ "$cmd" ]; then
		eval "./dmvpn-ca $cmd"
	fi
done < example.conf
