#! /bin/sh

sudo sh -c "curl -sSL https://get.docker.com/ | sh"
sudo /bin/systemctl enable docker || sudo chkconfig -add docker
sudo /bin/systemctl start docker
sudo /usr/bin/docker pull fedora:22
sudo /usr/bin/docker pull debian:jessie
sudo /usr/bin/docker pull busybox

sudo sh -c "curl -L https://github.com/docker/compose/releases/download/1.5.1/docker-compose-\"$(uname -s)\"-\"$(uname -m)\" > /usr/local/bin/docker-compose"
sudo chmod +x /usr/local/bin/docker-compose

sudo usermod -aG docker demo
