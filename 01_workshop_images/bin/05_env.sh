#! /bin/sh

sudo sh -c "echo 'demo:demo' | chpasswd"
sudo adduser demo sudo
sudo sh -c "echo 'LANG=en_US.UTF-8' >/etc/locale.conf"
sudo sh -c "echo 'LC_MESSAGES=C' >/etc/locale.conf"
sudo /usr/bin/localectl set-locale LANG=en_US.UTF-8
sudo sh -c "sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config"
