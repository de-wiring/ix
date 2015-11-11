#! /bin/sh

sudo sh -c "echo 'demo:demo' | chpasswd"
sudo sh -c "echo 'LANG=en_US.UTF-8' >/etc/locale.conf"
sudo sh -c "echo 'LC_MESSAGES=C' >/etc/locale.conf"
sudo /usr/bin/localectl set-locale LANG=en_US.UTF-8
