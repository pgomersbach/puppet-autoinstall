#!/bin/bash
apt-get install genisoimage
cd /tmp
mkdir original-iso custom-iso
if [ ! -f /tmp/ubuntu-14.04.3-server-amd64.iso ]; then
    echo "Iso image not found, downloading"
    wget http://releases.ubuntu.com/14.04/ubuntu-14.04.3-server-amd64.iso
fi
mount -o loop /tmp/ubuntu-14.04.3-server-amd64.iso ./original-iso
cp -r ./original-iso/* ./custom-iso/
cp -r ./original-iso/.disk/ ./custom-iso/
wget https://github.com/pgomersbach/puppet-autoinstall/raw/master/files/preseed-ubuntu-slave.seed -O ./custom-iso/preseed/seed.seed
umount ./original-iso/

cat > ./custom-iso/isolinux/menu.cfg << EOF
label custom1
menu label ^Install Ubuntu 14.04, apply puppet manifest add to foreman
kernel /install/vmlinuz
append file=/cdrom/preseed/seed.seed initrd=/install/initrd.gz locale=en_US auto=true console-setup/ask_detect=false keyboard-configuration/layoutcode=us

EOF

genisoimage -R -J -l -b isolinux/isolinux.bin -no-emul-boot -boot-load-size 4 -boot-info-table -z -iso-level 4 -c isolinux/isolinux.cat -o ubuntu-14.04.3-custom-amd64.iso custom-iso/
rm -rf original-iso custom-iso
echo "The custom iso image: /tmp/ubuntu-14.04.3-custom-amd64.iso"
cd -
