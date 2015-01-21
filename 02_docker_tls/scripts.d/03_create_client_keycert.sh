#!/bin/bash -x

# The MIT License (MIT)
# Copyright (c) 2015 de-wiring.net
#
# EXAMPLE script, NOT READY FOR PRODUCTION USE
#

# --
# given a ca, create key and cert for docker client

# must run as root
if [[ `id -u` != 0 ]]; then
	echo ERROR must run as root.
	exit 1
fi

CA_PATH=/etc/docker-tls

if [[ ! -d $CA_PATH ]]; then
	echo ERROR did not find ca path
	exit 2
fi

# generate key
( umask o-rwx,g-wx,u+rw; \
	openssl genrsa \
	-aes256 \
	-out $CA_PATH/private/client-key.pem \
	-passout file:./passphrase-file \
	4096
)

# generate request
openssl req \
	-subj '/CN=client' \
	-new \
	-config ./openssl.cnf \
	-key $CA_PATH/private/client-key.pem \
	-passin file:./passphrase-file \
	-out $CA_PATH/csr/client.csr \
	-batch

# sign w/ ext key usage
openssl x509 \
	-req \
	-in $CA_PATH/csr/client.csr \
	-passin file:./passphrase-file \
	-CAkey $CA_PATH/private/cakey.pem \
	-out $CA_PATH/certs/client-cert.pem \
	-CA $CA_PATH/cacert.pem \
	-CAserial $CA_PATH/serial \
	-extfile extfile.cnf

# unencrypt key
( umask o-rwx,g-wx,u+rw; \
	openssl rsa \
	-passin file:./passphrase-file \
	-in $CA_PATH/private/client-key.pem \
	-out $CA_PATH/private/client-key.pem
)

