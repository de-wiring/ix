#! /bin/sh

echo 'deb http://http.debian.net/debian jessie-backports main' >>/etc/apt/sources.list
export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get install -y vim git curl
LC_ALL=C /usr/sbin/useradd -m demo -s /bin/bash
LC_ALL=C adduser demo sudo
LC_ALL=C sed -i '/^%sudo/ s/ALL$/NOPASSWD:ALL/' /etc/sudoers

