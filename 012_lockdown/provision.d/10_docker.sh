#! /bin/sh

sudo sh -c "curl -sSL https://get.docker.com/ | sh"
LC_ALL=C sudo /bin/systemctl enable docker || sudo chkconfig -add docker
LC_ALL=C sudo /bin/systemctl start docker
