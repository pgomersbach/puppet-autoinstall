#!/bin/bash
apt-get install genisoimage
cd /tmp
mkdir original-iso custom-iso
wget http://cdimage.debian.org/debian-cd/6.0.4/i386/iso-cd/debian-6.0.4-i386-netinst.iso
mount -o loop debian-6.0.4-i386-netinst.iso ./original-iso
cp -r ./original-iso/* ./custom-iso/
cp -r ./original-iso/.disk/ ./custom-iso/
umount ./original-iso/

cat > ./custom-iso/isolinux/menu.cfg << EOF
label custom1
menu label ^Install Debian Puppet Server
kernel /install.386/vmlinuz
append url=http://puppet-autoinstall.googlecode.com/git/files/preseed-debian-puppet.seed initrd=/install.386/initrd.gz locale=en_US auto=true

label custom2
menu label ^Install Debian Slave Server
kernel /install.386/vmlinuz
append url=http://puppet-autoinstall.googlecode.com/git/files/preseed-debian-slave.seed initrd=/install.386/initrd.gz locale=en_US auto=true

label custom3
menu label ^Install Debian Development Server
kernel /install.386/vmlinuz
append url=http://puppet-autoinstall.googlecode.com/git/files/preseed-debian-develop.seed initrd=/install.386/initrd.gz locale=en_US auto=true
EOF

mkisofs -J -l -b isolinux/isolinux.bin -no-emul-boot -boot-load-size 4 -boot-info-table -z -iso-level 4 -c isolinux/isolinux.cat -o debian-6.0.4-i386-custom.iso custom-iso/

cd -
