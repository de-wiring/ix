#!/bin/sh

sudo sh -c 'echo "127.0.0.1 notaryserver" >> /etc/hosts'
sudo sh -c 'echo "127.0.0.1 sandboxregistry" >> /etc/hosts'
mkdir notarysandbox
cd notarysandbox || exit
mkdir notarytest
cd notarytest || exit
cp /tmp/Dockerfile .
docker build -t notarysandbox .
cd .. || exit
git clone -b trust-sandbox https://github.com/docker/notary.git
git clone https://github.com/docker/distribution.git
cd notary || exit
docker-compose build
cd ../distribution || exit
docker build -t sandboxregistry .
