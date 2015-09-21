#!/bin/sh
mkdir /boot/reinstall
wget http://ftp.nl.debian.org/debian/dists/squeeze/main/installer-i386/current/images/netboot/debian-installer/i386/initrd.gz -O /boot/reinstall/initrd.gz
wget http://ftp.nl.debian.org/debian/dists/squeeze/main/installer-i386/current/images/netboot/debian-installer/i386/linux -O /boot/reinstall/vmlinuz
hname=$(hostname)
dname=$(hostname -d)
cat > /etc/grub.d/07_reinstall << EOF
#!/bin/sh
exec tail -n +3 /etc/grub.d/07_reinstall
# This file provides an easy way to add custom menu entries.  Simply type the
# menu entries you want to add after this comment.  Be careful not to change
# the 'exec tail' line above.
menuentry 'Reinstallation' {
  insmod part_msdos
  insmod ext2
  set root=(hd0,1)
  linux /reinstall/vmlinuz url=http://puppet-autoinstall.googlecode.com/git/files/preseed-debian-slave.seed locale=en_US auto=true netcfg/get_hostname=$hname netcfg/get_domain=$dname
  initrd /reinstall/initrd.gz
}
EOF
chmod +x /etc/grub.d/07_reinstall
/usr/sbin/update-grub
sync
reboot
