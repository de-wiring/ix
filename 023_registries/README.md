# Content Trust with Notary 

## with local virtualbox
```
$ vagrant up
$ vagrant ssh
```

### 
```
demo@debian-jessie:~$ 
```

## with AWS/DO image

### fix up /etc/hosts
<host>$ sudo sh -c 'echo "127.0.0.1 notaryserver" >> /etc/hosts'
<host>$ sudo sh -c 'echo "127.0.0.1 sandboxregistry" >> /etc/hosts'

### start notary server and registry
```
<host>$ cd notarysandbox/notary
<host>$ sudo /usr/local/bin/docker-compose up -d
<host>$ cd ../distribution/
<host>$ sudo docker run -p 5000:5000 --name sandboxregistry sandboxregistry &
```

----
**Note: Open a second shell to the host to run the following commands.**
- step 1: download an unsigned image from the docker hub and tag it to be pushed to the sandbox registry
- result: after enabling content trust docker pull should fail

```
<host>$ sudo docker run -it -v /var/run/docker.sock:/var/run/docker.sock --link notary_notaryserver_1:notaryserver --link sandboxregistry:sandboxregistry notarysandbox
<sandbox_container>$ docker pull dewiring/trustit
<sandbox_container>$ docker tag -f dewiring/trustit sandboxregistry:5000/dewiring/trustit:latest
<sandbox_container>$ export DOCKER_CONTENT_TRUST=1
<sandbox_container>$ export DOCKER_CONTENT_TRUST_SERVER=https://notaryserver:4443
<sandbox_container>$ docker pull sandboxregistry:5000/dewiring/trustit
```

- step 2: push the trusted image, initial key generation and image tag signing will follow
- result: root key and repository should be generated, image tag should be signed, image should be pushed to sandbox registry
```
<sandbox_container>$ docker push sandboxregistry:5000/dewiring/trustit:latest
```

- step 3: pull trusted image
- result: image should be successfully pulled from sandbox registry
```
<sandbox_container>$ docker pull sandboxregistry:5000/dewiring/trustit
```

**Note: Open a third shell to the host to run the following commands.**
- step 4: poison an image
- result: image should not be pulled
```
<host>$ sudo docker exec -it sandboxregistry bash
<sandboxregistry_container>$ cd /var/lib/registry/docker/registry/v2/blobs/sha256/<sha256 image hash>
<sandboxregistry_container>$ echo "evil evil" > data
<sandbox_container>$ docker images | grep trustit
<sandbox_container>$ docker rmi -f <dewiring/trustit:latest>
<sandbox_container>$ docker pull sandboxregistry:5000/dewiring/trustit
```
