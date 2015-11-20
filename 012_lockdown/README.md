# Server lockdown

## hardening.io

### login to virtualbox
```
$ vagrant up
$ vagrant ssh
vagrant@debian-jessie:~$ sudo -i -u demo
```

### pull hardening.io repository
```
demo@debian-jessie:~$ git clone https://github.com/hardening-io/hardening.git
demo@debian-jessie:~$ cd hardening/puppet
```

### load puppet modules using librarian
```
demo@debian-jessie:~$ librarian-puppet install
```

### run puppet apply with hardening steps for os and ssh 
```
demo@debian-jessie:~$ sudo puppet apply manifests/default.pp --modulepath=./modules
```
