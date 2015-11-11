#! /bin/sh

sudo sh -c "curl -sSL https://get.docker.com/ | sh"
sudo /bin/systemctl enable docker || sudo chkconfig -add docker
sudo /bin/systemctl start docker
sudo /usr/bin/docker pull fedora:22
sudo /usr/bin/docker pull debian:jessie
sudo /usr/bin/docker pull busybox
