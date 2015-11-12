
echo 'deb http://http.debian.net/debian jessie-backports main' >>/etc/apt/sources.list
export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get install -y vim git curl ruby rubygems-integration

