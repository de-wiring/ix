
sudo su - -c "echo 'LANG=en_US.UTF-8
LC_MESSAGES=C' >/etc/locale.conf"

sudo localectl set-locale LANG=en_US.UTF-8

sudo /usr/bin/dnf update -y
sudo /usr/bin/dnf install -y git net-tools deltarpm


