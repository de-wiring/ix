# Using AppArmor for Docker containers

## Installation

Provisioning script install apparmor, including profiles and utilities, and enable it within GRUB. Reboot ist needed here.

```bash
~# DEBIAN_FRONTEND=noninteractive apt-get install -y \	
	apparmor apparmor-profiles apparmor-utils
~# perl -pi -e 's,GRUB_CMDLINE_LINUX="(.*)"$,GRUB_CMDLINE_LINUX="$1 apparmor=1 security=apparmor",' /etc/default/grub
~# update-grub
```

## Checking

`aa-status` shows that AppArmor is active, and what profiles will be enforced:

```bash
root@debian-jessie:~# aa-status
apparmor module is loaded.
40 profiles are loaded.
5 profiles are in enforce mode.
   /usr/lib/chromium-browser/chromium-browser//browser_java
   /usr/lib/chromium-browser/chromium-browser//browser_openjdk
   /usr/lib/chromium-browser/chromium-browser//sanitized_helper
   docker-default
35 profiles are in complain mode.
   /sbin/klogd
   /sbin/syslog-ng
(...)
   /{usr/,}bin/ping
0 processes have profiles defined.
0 processes are in enforce mode.
0 processes are in complain mode.
0 processes are unconfined but have a profile defined.

```

There is a small serverspec to auto-check some things about the installation:

```bash
~# cd /vagrant/spec.d
root@debian-jessie:/vagrant/spec.d# rake spec
/usr/bin/ruby2.1 -I/var/lib/gems/2.1.0/gems/rspec-support-3.1.2/lib:/var/lib/gems/2.1.0/gems/rspec-core-3.1.7/lib /var/lib/gems/2.1.0/gems/rspec-core-3.1.7/exe/rspec --pattern spec/localhost/\*_spec.rb

Package "apparmor"
  should be installed
(...)
Finished in 0.16097 seconds (files took 0.35781 seconds to load)
8 examples, 0 failures
```

## Docker's default mechanism

Docker daemon runs unconfined, containers are isolated by the `docker-default` profile:

```bash
~# docker run -tdi debian:jessie
d8d74ea1f3487b5faa93296bf834434e24f9f57e67905f33fc0e44f6941a60e2

~# ps -efZ | grep docker
unconfined        root   482   1  0 12:20 ?     00:00:05 /usr/bin/docker -d -H fd://
docker-default    root   932  82  0 12:35 pts/1 00:00:00 /bin/bash
```

## Creating a custom profile

In this small example, we just copy the `docker`default profile to a `docker-custom` profile and add a rule:

```bash
~# cd /etc/apparmor.d
~# cp docker docker-custom
~# vi docker-custom
```

add at end:

```
  # CUSTOM additions
  deny /sbin/bridge rwmx,
}

```

This way, we deny i.e. the execution of `/sbin/bridge`. Note the argument to docker run, `--security-opt="apparmor:docker-custom"`.

```bash
~# docker run -ti --security-opt="apparmor:docker-custom" debian:jessie /bin/bash
root@53d7a75bb3b2:/# /sbin/bridge
bash: /sbin/bridge: Permission denied
```


