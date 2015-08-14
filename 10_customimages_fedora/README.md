
# Custom Docker Images on Fedora 22

Using appliance-creator to build a custom fedora 22 base image.

## Base Image

Install necessary packages: appliance-tools for `appliance-creator` and libguestfs-tools for `virt-tar-out`.

```bash
~# dnf install -y appliance-tools libguestfs-tools
```

Create a workplace, put a kickstart (i.e. see [1]) file into it. Create some local dirs for appliance-creator to work in.

```bash
~# mkdir /root/minimal-image && cd /root/minimal-image
~# mkdir output
~# mkdir tmp
~# vi container-small-22.ks

# This is a kickstart for making a non-bootable container environment.

lang en_US.UTF-8
keyboard us
timezone --utc Etc/UTC

auth --useshadow --enablemd5
selinux --enforcing
rootpw --lock --iscrypted lockeddown00

zerombr
clearpart --all
part / --size 1024 --fstype ext4

# Repositories
repo --name=fedora --mirrorlist=http://mirrors.fedoraproject.org/mirrorlist?repo=fedora-22&arch=$basearch
repo --name=fedora-updates --mirrorlist=http://mirrors.fedoraproject.org/mirrorlist?repo=updates-released-f22&arch=$basearch

reboot

# Package list.
%packages --excludedocs

bash
coreutils
fedora-release
filesystem
findutils
grep
iproute
sed
setup
rootfiles
dnf
dnf-yum

# removed below
passwd
# https://bugzilla.redhat.com/show_bug.cgi?id=1004976
firewalld

-kernel

%end



%post --erroronfail

# setup systemd to boot to the right runlevel
echo -n "Setting default runlevel to multiuser text mode"
rm -f /etc/systemd/system/default.target
ln -s /lib/systemd/system/multi-user.target /etc/systemd/system/default.target
echo .

# create devices which appliance-creator does not
ln -s /proc/kcore /dev/core
mknod -m 660 /dev/loop0 b 7 0
mknod -m 660 /dev/loop1 b 7 1
rm -rf /dev/console
ln -s /dev/tty1 /dev/console

echo -n "Network fixes"
# initscripts don't like this file to be missing.
cat > /etc/sysconfig/network << EOF
NETWORKING=yes
NOZEROCONF=yes
EOF

# For cloud images, 'eth0' _is_ the predictable device name, since
# we don't want to be tied to specific virtual (!) hardware
rm -f /etc/udev/rules.d/70*
ln -s /dev/null /etc/udev/rules.d/80-net-name-slot.rules

# simple eth0 config, again not hard-coded to the build hardware
cat > /etc/sysconfig/network-scripts/ifcfg-eth0 << EOF
DEVICE="eth0"
BOOTPROTO="dhcp"
ONBOOT="yes"
TYPE="Ethernet"
EOF

# Import RPM GPG key
releasever=$(rpm -q --qf '%{version}\n' fedora-release)
basearch=$(uname -i)
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-fedora-$releasever-$basearch

rm -f /usr/lib/locale/locale-archive

# Setup locale properly
localedef -v -c -i en_US -f UTF-8 en_US.UTF-8

# generic localhost names
cat > /etc/hosts << EOF
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6

EOF
echo .


# Because memory is scarce resource in most cloud/virt environments,
# and because this impedes forensics, we are differing from the Fedora
# default of having /tmp on tmpfs.
echo "Disabling tmpfs for /tmp."
systemctl mask tmp.mount

echo "Removing random-seed so it's not the same in every image."
rm -f /var/lib/random-seed


echo "Compressing cracklib."
gzip -9 /usr/share/cracklib/pw_dict.pwd

echo "Minimizing locale-archive."
localedef --list-archive | grep -v en_US | xargs localedef --delete-from-archive
mv /usr/lib/locale/locale-archive /usr/lib/locale/locale-archive.tmpl
/usr/sbin/build-locale-archive
# this is really kludgy and will be fixed with a better way of building
# these containers
mv /usr/share/locale/en /usr/share/locale/en_US /tmp
rm -rf /usr/share/locale/*
mv /tmp/en /tmp/en_US /usr/share/locale/
mv /usr/share/i18n/locales/en_US /tmp
rm -rf /usr/share/i18n/locales/*
mv /tmp/en_US /usr/share/i18n/locales/
echo '%_install_langs C:en:en_US:en_US.UTF-8' >> /etc/rpm/macros.imgcreate

echo "Removing extra packages."
rm -vf /etc/yum/protected.d/*
dnf -C -y remove passwd --setopt="clean_requirements_on_remove=1"
dnf -C -y remove firewalld --setopt="clean_requirements_on_remove=1"

echo "Removing boot, since we don't need that."
rm -rf /boot/*

echo "Cleaning old yum repodata."
dnf clean all
rm -rf /var/lib/yum/yumdb/*
truncate -c -s 0 /var/log/yum.log

echo "Fixing SELinux contexts."
/usr/sbin/fixfiles -R -a restore


echo "Zeroing out empty space."
# This forces the filesystem to reclaim space from deleted files
dd bs=1M if=/dev/zero of=/var/tmp/zeros || :
rm -f /var/tmp/zeros
echo "(Don't worry -- that out-of-space error was expected.)"

%end
```

Build an appliance.

```bash
~# appliance-creator -c container-small-22.ks \
	-d -v \
	-t ./tmp/ \
	-o ./output/ \
	--name 'container-small-22' \
	--release 22 \
	--format qcow2

~# find output/
output/
output/container-small-22
output/container-small-22/container-small-22-sda.qcow2
output/container-small-22/container-small-22.xml
```

Take the qcow2 image (-a), export root dir (/) into a tarball (in ./tmp):

```bash
~# virt-tar-out -a output/container-small-22/container-small-22-sda.qcow2 / ./tmp/container-small-22.tar
```

Use docker import:

```bash
~# cat ./tmp/container-small-22.tar | docker import - my_fedora:22
~# docker run -ti my_fedora:22 /bin/bash

# look at the anaconda-ks log file, its mirrors our container-small-22.ks
[root@f6407d12cd9b /]# cat /root/anaconda-ks.cfg
```

This image is not yet a minimal, hardened base image, but can serve as a starting point for a hardening process.

```bash
# docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             VIRTUAL SIZE
my_fedora           22                  6f2942401a3e        25 minutes ago      191.8 MB
```

## Refs

[1] https://git.fedorahosted.org/cgit/cloud-kickstarts.git/plain/container/container-small-19.ks
[2] http://allthingsopen.com/2013/12/19/building-docker-images-on-fedora/

## License
The MIT License (MIT)
Copyright (c) 2015 Andreas Schmidt

