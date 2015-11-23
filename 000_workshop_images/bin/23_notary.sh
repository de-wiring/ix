#!/bin/sh

sudo sh -c 'echo "127.0.0.1 notaryserver" >> /etc/hosts'
sudo sh -c 'echo "127.0.0.1 sandboxregistry" >> /etc/hosts'

cd /home/demo || exit
mkdir notarysandbox
chown demo. notarysandbox
cd notarysandbox || exit

mkdir notarytest
chown demo. notarytest
cd notarytest || exit
curl https://raw.githubusercontent.com/de-wiring/ix/master/023_registries/provision.d/Dockerfile -o Dockerfile
docker build -t notarysandbox .

cd .. || exit
git clone -b trust-sandbox https://github.com/docker/notary.git
cd notary || exit
sudo /usr/local/bin/docker-compose build

cd .. || exit
git clone https://github.com/docker/distribution.git
cd distribution || exit
docker build -t sandboxregistry .
