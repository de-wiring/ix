#! /bin/sh

echo 'deb http://http.debian.net/debian jessie-backports main' >>/etc/apt/sources.list
export DEBIAN_FRONTEND=noninteractive
LC_ALL=C apt-get update -y
LC_ALL=C apt-get -y install vim git curl
LC_ALL=C /usr/sbin/useradd -m demo -s /bin/bash
LC_ALL=C adduser demo sudo
LC_ALL=C sed -i '/^%sudo/ s/ALL$/NOPASSWD:ALL/' /etc/sudoers
