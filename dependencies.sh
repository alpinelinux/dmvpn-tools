#!/bin/sh -e

sudo apk add --virtual .dmvpn-ca-deps lua5.2 lua5.2-lyaml lua5.2-ossl \
	lua-asn1 lua5.2-sql-sqlite3 lua5.2-stringy
