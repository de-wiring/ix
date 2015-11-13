# 05 Docker Auditd Configuration

After vagrant up, a `/demo/tests-docker-hardening` has been cloned with a serverspec suite.

## Checking that auditd is enabled and running

```bash
$ sudo auditctl -s
enabled 1
failure 1
pid 9945
rate_limit 0
backlog_limit 64
lost 58
backlog 0
backlog_wait_time 60000
loginuid_immutable 0 unlocked
```

## Configuring rules

Configure rules in `/etc/audit/audit.rules`. Insert a block:

```
# docker-related rules
-w /usr/bin/docker -k docker
-w /var/lib/docker -k docker
-w /etc/docker -k docker
-w /usr/lib/systemd/system/docker-registry.service -k docker
-w /usr/lib/systemd/system/docker.service -k docker
-w /var/run/docker.sock -k docker
-w /etc/sysconfig/docker -k docker
-w /etc/sysconfig/docker-network -k docker
-w /etc/sysconfig/docker-registry -k docker
-w /etc/sysconfig/docker-storage -k docker
-w /etc/default/docker -k docker
```

Restart the daemon (legacy restart due to systemd):

```bash
~# /usr/libexec/initscripts/legacy-actions/auditd/restart
Stopping logging:                                          [  OK  ]
Redirecting start to /bin/systemctl start auditd.service
```

Make sure that rules are active:

```bash
~# sudo auditctl -l
-a never,task
-w /usr/bin/docker -p rwxa -k docker
-w /var/lib/docker/ -p rwxa -k docker
(...)
```

## Serverspec suite

Run the suite, checks related to auditd should succeed:

```bash
[vagrant@localhost tests-docker-hardening]$ sudo -i
[root@localhost ~]# cd /demo/tests-docker-hardening/
[root@localhost tests-docker-hardening]# TARGET_HOST= /usr/local/bin/rake serverspec:default

1 - Host Configuration
  Linux audit system
    should be enabled
    should be running
  1.8 - Audit Docker Daemon
    Linux audit system
      should have audit rule /-w \/usr\/bin\/docker.*-k docker/
  1.9 - Audit Docker Files and Directories
    Linux audit system
      should have audit rule /-w \/var\/lib\/docker.*-k docker/
  1.10 - Audit Docker Files and Directories
    Linux audit system
      should have audit rule /-w \/etc\/docker.*-k docker/
  1.11 - Audit Docker Files and Directories - docker-registry on systemd
    Linux audit system
      should have audit rule /-w \/usr\/lib\/systemd\/system\/docker-registry\.service.*-k docker/
  1.12 - Audit Docker Files and Directories - docker.service on systemd
    Linux audit system
      should have audit rule /-w \/usr\/lib\/systemd\/system\/docker\.service.*-k docker/
  1.13 - Audit Docker Files and Directories - docker socket
    Linux audit system
      should have audit rule /-w \/var\/run\/docker\.sock.*-k docker/
  1.14 - Audit Docker Files and Directories - sysconfig/docker
    Linux audit system
      should have audit rule /-w \/etc\/sysconfig\/docker.*-k docker/
  1.15 - Audit Docker Files and Directories - sysconfig/docker-network
    Linux audit system
      should have audit rule /-w \/etc\/sysconfig\/docker-network.*-k docker/
  1.16 - Audit Docker Files and Directories - sysconfig/docker-registry
    Linux audit system
      should have audit rule /-w \/etc\/sysconfig\/docker-registry.*-k docker/
  1.17 - Audit Docker Files and Directories - sysconfig/docker-storage
    Linux audit system
      should have audit rule /-w \/etc\/sysconfig\/docker-registry.*-k docker/
  1.18 - Audit Docker Files and Directories - defaults
    Linux audit system
      should have audit rule /-w \/etc\/default\/docker.*-k docker/
```


