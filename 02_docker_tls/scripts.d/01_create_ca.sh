#!/bin/bash

# The MIT License (MIT)
# Copyright (c) 2015 de-wiring.net
#
# EXAMPLE script, NOT READY FOR PRODUCTION USE
#

# --
# create a ca structure

# must run as root
if [[ `id -u` != 0 ]]; then
	echo ERROR must run as root.
	exit 1
fi

CA_PATH=/etc/docker-tls

if [[ ! -d $CA_PATH ]]; then
	mkdir $CA_PATH
	chmod 0700 $CA_PATH
fi

# create file/dir structure
( umask o-rwx,g-wx,u+rw; \
	mkdir $CA_PATH/certs $CA_PATH/private $CA_PATH/csr >/dev/null 2>&1
	[[ -f $CA_PATH/serial ]] || echo '100001' >$CA_PATH/serial
	touch $CA_PATH/certindex.txt
)

# generate key, use passphase file
# to encrypt output
if [[ ! -f $CA_PATH/private/ca-key.pem ]]; then
	( umask o-rwx,g-wx,u+rw; \
		openssl req -new \
			-x509 \
			-keyout $CA_PATH/private/cakey.pem \
			-passout file:./passphrase-file \
			-out $CA_PATH/cacert.pem \
			-config ./openssl.cnf \
			-batch
	)
fi

