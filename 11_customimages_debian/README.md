# Debian Custom Images for Docker

##

```bash
root@debian-jessie:/vagrant/provision.d# apt-get install debootstrap
root@debian-jessie:/vagrant/provision.d# /usr/share/docker.io/contrib/mkimage.sh
usage: mkimage.sh [-d dir] [-t tag] script [script-args]
   ie: mkimage.sh -t someuser/debian debootstrap --variant=minbase jessie
       mkimage.sh -t someuser/ubuntu debootstrap --include=ubuntu-minimal --components=main,universe trusty
       mkimage.sh -t someuser/busybox busybox-static
       mkimage.sh -t someuser/centos:5 rinse --distribution centos-5
       mkimage.sh -t someuser/mageia:4 mageia-urpmi --version=4
       mkimage.sh -t someuser/mageia:4 mageia-urpmi --version=4 --mirror=http://somemirror/

root@debian-jessie:/vagrant/provision.d# debootstrap --help
Usage: debootstrap [OPTION]... <suite> <target> [<mirror> [<script>]]
Bootstrap a Debian base system into a target directory.

      --help                 display this help and exit
      --version              display version information and exit
      --verbose              don't turn off the output of wget

      --download-only        download packages, but don't perform installation
      --print-debs           print the packages to be installed, and exit

      --arch=A               set the architecture to install (use if no dpkg)
                               [ --arch=powerpc ]

      --include=A,B,C        adds specified names to the list of base packages
      --exclude=A,B,C        removes specified packages from the list
      --components=A,B,C     use packages from the listed components of the
                             archive
      --variant=X            use variant X of the bootstrap scripts
                             (currently supported variants: buildd, fakechroot,
                              scratchbox, minbase)
      --keyring=K            check Release files against keyring K
      --no-check-gpg         avoid checking Release file signatures
      --no-resolve-deps      don't try to resolve dependencies automatically

      --unpack-tarball=T     acquire .debs from a tarball instead of http
      --make-tarball=T       download .debs and create a tarball (tgz format)
      --second-stage-target=DIR
                             Run second stage in a subdirectory instead of root
                               (can be used to create a foreign chroot)
                               (requires --second-stage)
      --extractor=TYPE       override automatic .deb extractor selection
                               (supported: dpkg-deb ar)
      --debian-installer     used for internal purposes by debian-installer
      --private-key=file     read the private key from file
      --certificate=file     use the client certificate stored in file (PEM)
      --no-check-certificate do not check certificate against certificate authorities
```

Run mkimage.sh with debootstrap, go with --verbose:

```bash
root@debian-jessie:/vagrant/provision.d# /usr/share/docker.io/contrib/mkimage.sh -d /root -t de-wiring/debian:jessie debootstrap --verbose --variant=minbase jessie
+ mkdir -p /root/rootfs
+ debootstrap --verbose --variant=minbase jessie /root/rootfs
I: Retrieving Release
I: Retrieving Release.gpg
I: Checking Release signature
I: Valid Release signature (key id 75DDC3C4A499F1A18CB5F3C8CBF8D6FD518E17E1)
I: Retrieving Packages
I: Validating Packages
I: Resolving dependencies of required packages...
I: Resolving dependencies of base packages...
I: Found additional required dependencies: acl adduser dmsetup insserv libaudit-common libaudit1 libbz2-1.0 libcap2 libcap2-bin libcryptsetup4 libdb5.3 libdebconfclient0 libdevmapper1.02.1 libgcrypt20 libgpg-error0 libkmod2 libncursesw5 libprocps3 libsemanage-common libsemanage1 libslang2 libsystemd0 libudev1 libustr-1.0-1 procps systemd systemd-sysv udev
I: Found additional base dependencies: debian-archive-keyring gnupg gpgv libapt-pkg4.12 libreadline6 libstdc++6 libusb-0.1-4 readline-common
I: Checking component main on http://ftp.us.debian.org/debian...
I: Retrieving acl 2.2.52-2

(... retrieving, extracting, installing packages ...)

I: Base system installed successfully.
+ echo exit 101 > '/root/rootfs/usr/sbin/policy-rc.d'
+ rootfs_chroot dpkg-divert --local --rename --add /sbin/initctl
+ PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
+ /usr/sbin/chroot /root/rootfs dpkg-divert --local --rename --add /sbin/initctl
Adding 'local diversion of /sbin/initctl to /sbin/initctl.distrib'
+ cp -a /root/rootfs/usr/sbin/policy-rc.d /root/rootfs/sbin/initctl
+ sed -i 's/^exit.*/exit 0/' /root/rootfs/sbin/initctl
+ rootfs_chroot apt-get clean
+ PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
+ /usr/sbin/chroot /root/rootfs apt-get clean
+ echo force-unsafe-io > '/root/rootfs/etc/dpkg/dpkg.cfg.d/docker-apt-speedup'
+ cat > '/root/rootfs/etc/apt/apt.conf.d/docker-clean'
+ echo Acquire::Languages 'none' > '/root/rootfs/etc/apt/apt.conf.d/docker-no-languages'
+ echo Acquire::GzipIndexes 'true' > '/root/rootfs/etc/apt/apt.conf.d/docker-gzip-indexes'
+ echo Apt::AutoRemove::SuggestsImportant 'false' > '/root/rootfs/etc/apt/apt.conf.d/docker-autoremove-suggests'
+ sed -i '
						p;
						s/ jessie / jessie-updates /
					' /root/rootfs/etc/apt/sources.list
+ echo 'deb http://security.debian.org jessie/updates main'
+ '[' jessie = squeeze -o jessie = oldstable ']'
+ rootfs_chroot sh -xc 'apt-get update && apt-get dist-upgrade -y'
+ PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
+ /usr/sbin/chroot /root/rootfs sh -xc 'apt-get update && apt-get dist-upgrade -y'
+ apt-get update
Get:1 http://security.debian.org jessie/updates InRelease [63.1 kB]
Get:2 http://security.debian.org jessie/updates/main amd64 Packages [165 kB]
Get:3 http://ftp.us.debian.org jessie InRelease [134 kB]
Get:4 http://ftp.us.debian.org jessie-updates InRelease [123 kB]
Get:5 http://ftp.us.debian.org jessie/main amd64 Packages [9038 kB]
Get:6 http://ftp.us.debian.org jessie-updates/main amd64 Packages [3614 B]
Fetched 9527 kB in 24s (395 kB/s)
Reading package lists... Done
+ apt-get dist-upgrade -y
Reading package lists... Done
Building dependency tree... Done
Calculating upgrade... Done
The following packages will be upgraded:
  tzdata
1 upgraded, 0 newly installed, 0 to remove and 0 not upgraded.
Need to get 191 kB of archives.
After this operation, 0 B of additional disk space will be used.
Get:1 http://ftp.us.debian.org/debian/ jessie-updates/main tzdata all 2015f-0+deb8u1 [191 kB]
Fetched 191 kB in 6s (31.6 kB/s)
perl: warning: Setting locale failed.
perl: warning: Please check that your locale settings:
	LANGUAGE = (unset),
	LC_ALL = (unset),
	LANG = "en_US.UTF-8"
    are supported and installed on your system.
perl: warning: Falling back to the standard locale ("C").
locale: Cannot set LC_CTYPE to default locale: No such file or directory
locale: Cannot set LC_MESSAGES to default locale: No such file or directory
locale: Cannot set LC_ALL to default locale: No such file or directory
debconf: delaying package configuration, since apt-utils is not installed
E: Can not write log (Is /dev/pts mounted?) - posix_openpt (2: No such file or directory)
(Reading database ... 7423 files and directories currently installed.)
Preparing to unpack .../tzdata_2015f-0+deb8u1_all.deb ...
Unpacking tzdata (2015f-0+deb8u1) over (2015d-0+deb8u1) ...
Setting up tzdata (2015f-0+deb8u1) ...
debconf: unable to initialize frontend: Dialog
debconf: (No usable dialog-like program is installed, so the dialog based frontend cannot be used. at /usr/share/perl5/Debconf/FrontEnd/Dialog.pm line 76.)
debconf: falling back to frontend: Readline
debconf: unable to initialize frontend: Readline
debconf: (Can't locate Term/ReadLine.pm in @INC (you may need to install the Term::ReadLine module) (@INC contains: /etc/perl /usr/local/lib/x86_64-linux-gnu/perl/5.20.2 /usr/local/share/perl/5.20.2 /usr/lib/x86_64-linux-gnu/perl5/5.20 /usr/share/perl5 /usr/lib/x86_64-linux-gnu/perl/5.20 /usr/share/perl/5.20 /usr/local/lib/site_perl .) at /usr/share/perl5/Debconf/FrontEnd/Readline.pm line 7.)
debconf: falling back to frontend: Teletype

Current default time zone: 'Etc/UTC'
Local time is now:      Fri Aug 14 15:50:19 UTC 2015.
Universal Time is now:  Fri Aug 14 15:50:19 UTC 2015.
Run 'dpkg-reconfigure tzdata' if you wish to change it.

+ rm -rf /root/rootfs/var/lib/apt/lists/ftp.us.debian.org_debian_dists_jessie_InRelease /root/rootfs/var/lib/apt/lists/ftp.us.debian.org_debian_dists_jessie_main_binary-amd64_Packages.gz /root/rootfs/var/lib/apt/lists/ftp.us.debian.org_debian_dists_jessie-updates_InRelease /root/rootfs/var/lib/apt/lists/ftp.us.debian.org_debian_dists_jessie-updates_main_binary-amd64_Packages.gz /root/rootfs/var/lib/apt/lists/lock /root/rootfs/var/lib/apt/lists/partial /root/rootfs/var/lib/apt/lists/security.debian.org_dists_jessie_updates_InRelease /root/rootfs/var/lib/apt/lists/security.debian.org_dists_jessie_updates_main_binary-amd64_Packages.gz
+ mkdir /root/rootfs/var/lib/apt/lists/partial
+ tar --numeric-owner -caf /root/rootfs.tar.xz -C /root/rootfs '--transform=s,^./,,' .
+ cat > '/root/Dockerfile'
+ echo 'CMD ["/bin/bash"]'
+ rm -rf /root/rootfs
+ docker build -t de-wiring/debian:jessie /root
Sending build context to Docker daemon 29.41 MB
Sending build context to Docker daemon
Step 0 : FROM scratch
 --->
Step 1 : ADD rootfs.tar.xz /
 ---> 883140c8c0c8
Removing intermediate container a11020579f01
Step 2 : CMD /bin/bash
 ---> Running in bd25c3eaf646
 ---> e744ddd85a62
Removing intermediate container bd25c3eaf646
Successfully built e744ddd85a62
root@debian-jessie:/vagrant/provision.d#
```

```bash
~# root@debian-jessie:~# ls -alh /root/rootfs.tar.xz
-rw-r--r-- 1 root root 29M Aug 14 15:51 /root/rootfs.tar.xz

~# docker images
REPOSITORY          TAG                 IMAGE ID            CREATED              VIRTUAL SIZE
de-wiring/debian    jessie              e744ddd85a62        About a minute ago   123.8 MB
```
