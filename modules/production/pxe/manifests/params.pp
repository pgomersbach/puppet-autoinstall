class pxe::params {

  $syslinux_archive = "http://www.kernel.org/pub/linux/utils/boot/syslinux/4.xx/syslinux-4.04.tar.gz"
  $syslinux_dir = "/usr/local/src/syslinux-4.04"
  include tftp
  permute { "Windows Installers":
    resource => 'pxe::installer',
    unique   => {
      arch => ["amd64"],
      ver  => ["2008"],
      os   => "windows"
    },
    common   => {
      file   => "os_<%= os %>",
      kernel => "memdisk",
      append => "iso initrd=images/<%= os %>/winpe_<%= arch %>.iso",
    },
  }

  permute { "Windows PE":
    resource => 'pxe::installer',
    unique   => {
      arch => ["amd64"],
      ver  => ["2008"],
      os   => "windowspe"
    },
    common   => {
      file   => "os_<%= os %>",
      kernel => "memdisk",
      append => "iso initrd=images/<%= os %>/<%= ver %>/<%= arch %>/Rescue.iso",
    },
  }



  permute { "Debian Installers":
    resource => 'pxe::installer',
    unique   => {
      arch => ["amd64","i386"],
      ver  => ["squeeze","wheezy"],
      os   => "debian"
    },
    common   => {
      file   => "os_<%= os %>",
      kernel => "images/<%= os %>/<%= ver %>/<%= arch %>/linux",
      append => "initrd=images/<%= os %>/<%= ver %>/<%= arch %>/initrd.gz text",
    },
  }

  permute { "Ubuntu Installers":
    resource => 'pxe::installer',
    unique   => {
      arch => ["amd64","i386"],
      ver  => ["lucid","precise","quantal","raring"],
      os   => "ubuntu",
    },
    common   => {
      file    => "os_<%= os %>",
      kernel  => "images/<%= os %>/<%= ver %>/<%= arch %>/linux",
      append  => "initrd=images/<%= os %>/<%= ver %>/<%= arch %>/initrd.gz text",
    },
  }

  permute { "CentOS Installers":
    resource => 'pxe::installer',
    unique   => {
      arch => ["x86_64","i386"],
      ver  => [5,6],
      os   => "centos"
    },
    common   => {
      file   => "os_<%= os %>",
      kernel => "images/<%= os %>/<%= ver %>/<%= arch %>/vmlinuz",
      append => "initrd=images/<%= os %>/<%= ver %>/<%= arch %>/initrd.img text",
    },
  }

  permute { "Fedora Installers":
    resource => 'pxe::installer',
    unique   => {
      arch => ["x86_64","i386"],
      ver  => ["15","16","17"],
      os   => "fedora"
    },
    common   => {
      baseurl => "http://mirrors.kernel.org/fedora/releases/<%= ver %>/Fedora/<%= arch %>/os/images/pxeboot/",
      file    => "os_<%= os %>",
      kernel  => "images/<%= os %>/<%= ver %>/<%= arch %>/vmlinuz",
      append  => "initrd=images/<%= os %>/<%= ver %>/<%= arch %>/initrd.img text",
    },
  }

  # ----------
  # FreeBSD and Friends
  # ----------
  permute { "FreeBSD and Friends":
    resource => 'pxe::installer',
    unique   => {
      arch => ["amd64"],
      ver  => "se-9.0-RELEASE",
      os   => "mfsbsd"
    },
    common   => {
      file   => "os_<%= os %>",
      kernel => "memdisk raw",
      append => "initrd=images/mfsbsd/<%= os %>-<%= ver %>-<%= arch %>.img"
    },
  }

  # ----------
  # ESXi
  # ----------
  pxe::menu::entry { "ESXi 5.1":
    file   => "menu_install",
    kernel => "images/esxi51/mboot.c32",
    append => "-c images/esxi51/boot.cfg",
  }

  # ----------
  # Operations
  # ----------
  pxe::menu { "Deployments": file => "menu_deploy", }

  permute { "Debian Ops":
    resource => "pxe::menu::installentry",
    unique   => {
      arch   => ["i386","amd64"],
      ver    => ["squeeze","wheezy"],
      os     => ["debian"],
    },
    common => {
      file      => "menu_deploy",
      kernel    => "images/<%= os %>/<%= ver %>/<%= arch %>/linux",
      append    => "initrd=images/<%= os %>/<%= ver %>/<%= arch %>/initrd.gz auto locale=en_US console-keymaps-at/keymap=us domain=<%= domain %> url=http://puppet-autoinstall.googlecode.com/git/files/preseed-debian-slave.seed text suite=<%= ver %>",
      menutitle => "Puppet slave auto-deployment <%= os %> <%= ver %> <%= arch %>",
    },
  }

  permute { "Ubuntu Ops":
    resource => "pxe::menu::installentry",
    unique   => {
      arch   => ["i386","amd64"],
      ver    => ["precise","quantal"],
      os     => ["ubuntu"],
    },
    common => {
      file      => "menu_deploy",
      kernel    => "images/<%= os %>/<%= ver %>/<%= arch %>/linux",
      append    => "initrd=images/<%= os %>/<%= ver %>/<%= arch %>/initrd.gz auto vga=normal ramdisk_size=16384 root=/dev/ram rw debian-installer/locale=en_US debian-installer/keymap=us console-keymaps-at/keymap=us console-setup/ask_detect=false netcfg/choose_interface=eth0 domain=<%= domain %> preseed/url=http://puppet-autoinstall.googlecode.com/git/files/preseed-ubuntu-quick.seed text suite=<%= ver %>",
      menutitle => "Ubuntu quick-deployment <%= os %> <%= ver %> <%= arch %>",
    },
  }

  permute { "Ubuntu foreman.ssx.nl client":
    resource => "pxe::menu::installentry",
    unique   => {
      arch   => ["i386","amd64"],
      ver    => ["precise","quantal"],
      os     => ["ubuntu"],
    },
    common => {
      file      => "menu_deploy",
      kernel    => "images/<%= os %>/<%= ver %>/<%= arch %>/linux",
      append    => "initrd=images/<%= os %>/<%= ver %>/<%= arch %>/initrd.gz auto vga=normal ramdisk_size=16384 root=/dev/ram rw debian-installer/locale=en_US debian-installer/keymap=us console-keymaps-at/keymap=us console-setup/ask_detect=false netcfg/choose_interface=eth0 domain=<%= domain %> preseed/url=http://puppet-autoinstall.googlecode.com/git/files/preseed-ubuntu-puppet.seed text suite=<%= ver %>",
      menutitle => "Ubuntu foreman.ssx.nl client <%= os %> <%= ver %> <%= arch %>",
    },
  }


### Menus

  pxe::menu {
      'Main Menu':
        file      => "default",
        template  => "pxe/menu_default.erb";
    }

}

