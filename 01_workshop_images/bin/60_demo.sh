#!/bin/sh

if [ ! -d /home/demo/tests-docker-hardening ]; then
	sudo su - demo -c "cd /home/demo && curl -sSL https://raw.githubusercontent.com/de-wiring/ix/master/01_workshop_images/demo_pull.sh | sh"
fi
