#!/bin/sh

sudo apk add -t .dmvpn-tools-deps \
	lua5.2 lua5.2-cqueues lua5.2-lyaml lua5.2-ossl lua5.2-posix \
	lua5.2-sql-sqlite3 lua5.2-stringy lua5.2-struct lua-asn1
