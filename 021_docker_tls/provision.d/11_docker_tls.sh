
IPA=`ip a s eth0 | grep "inet " | tr '/' ' ' | awk '{ print $2 }'`

grep -wq docker-server.local /etc/hosts >/dev/null 2>&1
if [[ $? -ne 0 ]]; then
	echo "$IPA docker-server.local" >>/etc/hosts
fi

grep -wq TLS_ENABLE_OPS /etc/default/docker >/dev/null 2>&1
if [[ $? -ne 0 ]]; then
	echo '# TLS_ENABLE_OPS provisioning.d/11_docker_tls.sh' >>/etc/default/docker
	echo 'DOCKER_OPTS="$DOCKER_OPTS --tlsverify --tlscacert=/etc/docker-tls/cacert.pem --tlscert=/etc/docker-tls/certs/server-cert.pem --tlskey=/etc/docker-tls/private/server-key.pem -H='$IPA':2376"' >>/etc/default/docker
fi



