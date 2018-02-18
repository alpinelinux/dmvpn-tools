#!/bin/sh -e

# Create test database for dmvpn-ca
#
# Copyright (c) 2014-2018 Kaarle Ritvanen
# Copyright (c) 2017 Natanael Copa
#
# See LICENSE file for license details

./dependencies.sh

while read cmd; do
	if [ "$cmd" ]; then
		eval "./dmvpn-ca $cmd"
	fi
done < example.conf
