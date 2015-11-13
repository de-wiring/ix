
if [[ ! -d /demo ]]; then
	mkdir /demo
	chown -R vagrant:vagrant /demo
	chmod 775 /demo
fi

# 
if [[ ! -d /demo/tests-docker-hardening ]]; then
	sudo su - vagrant -c "cd /demo && git clone https://github.com/de-wiring/tests-docker-hardening"
fi

