#!/bin/sh

# Install dependencies for dmvpn-tools
#
# Copyright (c) 2014-2018 Kaarle Ritvanen
# Copyright (c) 2017 Natanael Copa
#
# See LICENSE file for license details

sudo apk add -t .dmvpn-tools-deps \
	lua5.2 lua5.2-cqueues lua5.2-lyaml lua5.2-ossl lua5.2-posix \
	lua5.2-sql-sqlite3 lua5.2-stringy lua5.2-struct lua-asn1
