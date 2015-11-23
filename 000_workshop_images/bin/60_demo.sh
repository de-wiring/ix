#!/bin/sh

if [ ! -f /home/demo/demo_pull.sh ]; then
	sudo su - demo -c "cd /home/demo && curl -sSL https://raw.githubusercontent.com/de-wiring/ix/master/000_workshop_images/demo_pull.sh | bash"
fi
