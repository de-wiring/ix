
sudo /usr/bin/dnf install -y \
	docker \
	docker-vim 

sudo systemctl enable docker || chkconfig -add docker
sudo systemctl start docker || chkconfig -add docker

docker pull fedora:23



