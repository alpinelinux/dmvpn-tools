#!/bin/sh -e

sudo apk add --virtual .dmvpn-ca-deps lua5.2 lua5.2-lyaml lua5.2-ossl \
	lua5.2-posix lua5.2-sql-sqlite3 lua5.2-stringy lua-asn1
