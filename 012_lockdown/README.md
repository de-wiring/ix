# Server lockdown w/ hardening.io

## with local virtualbox
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

## with AWS/DO image

### install puppet
| Fedora                                 | Ubuntu                                 |
| -------------------------------------- | -------------------------------------- |
| ```$ sudo dnf -y install puppet```     | ```$ sudo apt-get -y install puppet``` |

### install current librarian-puppet
```
$ sudo -i -u demo
$ PATH="$(ruby -rubygems -e 'puts Gem.user_dir')/bin:$PATH"
$ gem install librarian-puppet --user-install
```

### pull hardening.io repository
```
$ git clone https://github.com/hardening-io/hardening.git
$ cd hardening/puppet
```

### load puppet modules using librarian
```
$ librarian-puppet install
```

### run puppet apply with hardening steps for os and ssh 
```
$ sudo puppet apply manifests/default.pp --modulepath=./modules
```
