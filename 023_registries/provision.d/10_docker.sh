#! /bin/sh

sudo sh -c "curl -sSL https://get.docker.com/ | sh"
sudo /bin/systemctl enable docker || sudo chkconfig -add docker
sudo /bin/systemctl start docker
sudo /usr/bin/docker pull dewiring/trustit

sudo usermod -aG docker demo
