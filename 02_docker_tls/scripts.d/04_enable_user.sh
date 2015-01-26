#!/bin/bash 

# The MIT License (MIT)
# Copyright (c) 2015 de-wiring.net
#
# EXAMPLE script, NOT READY FOR PRODUCTION USE
#

# --
# enable docker access for a given user by copying
# client keys to <home-directory>/.docker

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

TARGET_USER=$1
if [[ -z "$TARGET_USER" ]]; then
	echo ERROR Please supply user name as 1st parameter
	exit 3
fi

id $TARGET_USER >/dev/null 2>&1
if [[ $? -ne 0 ]]; then
	echo ERROR No such user $TARGET_USER
	exit 4
fi

homedir=$( getent passwd "$TARGET_USER" | cut -d: -f6 )
if [[ ! -d $homedir/.docker ]]; then
	mkdir $homedir/.docker
	chown $TARGET_USER $homedir/.docker
	chmod 700 $homedir/.docker
fi

# copy certs
cp $CA_PATH/cacert.pem $homedir/.docker/ca.pem
cp $CA_PATH/certs/client-cert.pem $homedir/.docker/cert.pem
cp $CA_PATH/private/client-key.pem $homedir/.docker/key.pem

for f in ca.pem cert.pem key.pem; do
	chown $TARGET_USER $homedir/.docker/$f
	chmod 0400 $homedir/.docker/$f
done

DOCKER_SERVER_HOSTNAME=`openssl x509 -in /etc/docker-tls/certs/server-cert.pem -text | grep "Subject:" | sed -e 's/.*CN=\(.*\)$/\1/g'`

# extend users bashrc
F=$homedir/.bashrc
if [[ -f $F ]]; then
	grep -wq DOCKER_TLS_SETUP $F 
	if [[ $? -ne 0 ]]; then
		echo '# DOCKER_TLS_SETUP' >>$F
		echo "export DOCKER_HOST=tcp://$DOCKER_SERVER_HOSTNAME:2376" >>$F
		echo 'export DOCKER_TLS_VERIFY=1' >> $F
	fi
fi

