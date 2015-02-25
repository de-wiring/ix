# Sample Docker TLS setup including serverspecs

Start demo virtual machine:

```bash
$ vagrant up
(...)
$ vagrant ssh
```

It will install an ubuntu/trusty64 with docker installed and a preconfigured `/etc/default/docker` reflecting a tls setup with keys and certs expected in `/etc/docker-tls`:

```
DOCKER_OPTS="$DOCKER_OPTS --tlsverify --tlscacert=/etc/docker-tls/cacert.pem --tlscert=/etc/docker-tls/certs/server-cert.pem --tlskey=/etc/docker-tls/private/server-key.pem -H=10.0.2.15:2376"
```

Keys and certificates need to be generated, i.e. by using scripts in `/vagrant/scripts.d`. These scripts

* build ca key and certificate (`01_create_ca.sh`),
* build a key for the docker daemon, sign it and generate a dhparam (`02_create_server_keycert.sh`)
* build a key for the client application, sign it (`03_create_client_keycert.sh`)
* modify a users environment to turn on tls on docker client (`04_enable_user.sh`)

```bash
$ sudo -i
# cd /vagrant/scripts.d
# vi openssl.cnf

 << Change default entries in req_distinguished_name to match your company, locality etc. >>

# ./01_create_ca.sh
Generating a 4096 bit RSA private key
...........................................................................++
.........++
writing new private key to '/etc/docker-tls/private/cakey.pem'

# ./02_create_server_keycert.sh
Generating RSA private key, 4096 bit long modulus
............................................................................................................++
........................++
e is 65537 (0x10001)
Signature ok
subject=/CN=docker-server.local
Getting CA Private Key
writing RSA key

# ./03_create_client_keycert.sh
Generating RSA private key, 4096 bit long modulus
..++
.............................................++
e is 65537 (0x10001)
Signature ok
subject=/CN=client
Getting CA Private Key
writing RSA key

# ./04_enable_user.sh vagrant
```

We need to restart the docker daemon, so it can pick up tls config and keys:
```bash
# service docker restart
docker stop/waiting
docker start/running, process 14226
```

We can check the setup afterwards using a serverspec:

```bash
# rake spec
/usr/bin/ruby1.9.1 -I/var/lib/gems/1.9.1/gems/rspec-support-3.2.2/lib:/var/lib/gems/1.9.1/gems/rspec-core-3.2.1/lib /var/lib/gems/1.9.1/gems/rspec-core-3.2.1/exe/rspec --pattern spec/localhost/\*_spec.rb
..........................................................

Finished in 1.44 seconds (files took 0.51209 seconds to load)
58 examples, 0 failures
```

or, more verbose:

```bash
# rake spec SPEC_OPTS="--format documentation"
(...)
keys and certs should be present and valid
  File "/etc/docker-tls/private/server-key.pem"
    should be file
    should be owned by "root"
(...)
```

Above, we enabled the vagrant user to automatically use tls by giving him certificate files to `~/.docker` and adding environment variables to his `.bashrc`. We need to log in again to use them:

```bash
# exit
$ exit

$ vagrant ssh

$ docker info
(...)
```
 
