DEBIAN_FRONTEND=noninteractive apt install -y apparmor apparmor-profiles apparmor-utils
perl -pi -e 's,GRUB_CMDLINE_LINUX="(.*)"$,GRUB_CMDLINE_LINUX="$1 apparmor=1 security=apparmor",' /etc/default/grub
update-grub


