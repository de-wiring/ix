#!/bin/bash -x

# --
# given a ca, create key and cert for docker daemon (server part)

# must run as root
if [[ `id -u` != 0 ]]; then
	echo ERROR must run as root.
	exit 1
fi

CA_PATH=/etc/docker-tls
SERVER_CERT_SUBJECT=/CN=docker-server.local

if [[ ! -d $CA_PATH ]]; then
	echo ERROR did not find ca path
	exit 2
fi

# generate key
( umask o-rwx,g-wx,u+rw; \
	openssl genrsa \
	-aes256 \
	-out $CA_PATH/private/server-key.pem \
	-passout file:./passphrase-file \
	4096
)

# generate request
openssl req \
	-subj $SERVER_CERT_SUBJECT \
	-new \
	-config ./openssl.cnf \
	-key $CA_PATH/private/server-key.pem \
	-passin file:./passphrase-file \
	-out $CA_PATH/csr/server.csr \
	-batch

# sign w/ ext key usage
openssl x509 \
	-req \
	-in $CA_PATH/csr/server.csr \
	-passin file:./passphrase-file \
	-CAkey $CA_PATH/private/cakey.pem \
	-out $CA_PATH/certs/server-cert.pem \
	-CA $CA_PATH/cacert.pem \
	-CAserial $CA_PATH/serial \
	-extfile extfile.cnf

# unencrypt key
( umask o-rwx,g-wx,u+rw; \
	openssl rsa \
	-passin file:./passphrase-file \
	-in $CA_PATH/private/server-key.pem \
	-out $CA_PATH/private/server-key.pem
)

