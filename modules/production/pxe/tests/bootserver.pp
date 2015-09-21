class service::bootserver {

  motd::register { "PXE and TFTP boot server": }

  # ----------
  # Server Setup
  # ----------
  #class { "pxe": }
  #class { "tftp": }

  #file { "/var/www/boot.${domain}": ensure => directory; }
  #nginx::vhost { "boot.${domain}":
  #    port => 80,
  #}

  # ----------
  # Seeds
  # ----------
  #preseed { "/var/www/boot.${domain}/d-i/debian_base.cfg": }
  #preseed { "/var/www/boot.${domain}/d-i/debian_ops.cfg": }

  # ----------
  # Basic images for manuall install
  # ----------
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
      ver  => ["lucid","maverick","natty","oneiric","precise"],
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

  permute { "RedHat Installers":
    resource => 'pxe::installer',
    unique   => {
      arch => ["x86_64","i386"],
      ver  => "6",
      os   => "redhat"
    },
    common   => {
      baseurl => "http://yo.puppetlabs.lan/rhel<%= ver %>server-<%= arch %>/disc1/images/pxeboot",
      file    => "os_<%= os %>",
      kernel  => "images/<%= os %>/<%= ver %>/<%= arch %>/vmlinuz",
      append  => "initrd=images/<%= os %>/<%= ver %>/<%= arch %>/initrd.img text",
    },
  }

  permute { "Scientific Linux Installers":
    resource => 'pxe::installer',
    unique   => {
      arch => ["x86_64","i386"],
      ver  => "6.0",
      os   => "scientific"
    },
    common   => {
      baseurl => "http://mirror.yellowfiber.net/scientific/<%= ver %>/<%= arch %>/os/images/pxeboot/",
      file    => "os_<%= os %>",
      kernel  => "images/<%= os %>/<%= ver %>/<%= arch %>/vmlinuz",
      append  => "initrd=images/<%= os %>/<%= ver %>/<%= arch %>/initrd.img text",
    },
  }

  permute { "Fedora Installers":
    resource => 'pxe::installer',
    unique   => {
      arch => ["x86_64","i386"],
      ver  => "15",
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
  pxe::menu::entry { "ESXi 5.0":
    file   => "menu_install",
    kernel => "images/esxi50/mboot.c32",
    append => "-c images/esxi50/boot.cfg",
  }

  # ----------
  # Operations
  # ----------
  pxe::menu { "Deployments": file => "menu_deploy", }

  permute { "Debian Ops":
    resource => "pxe::menu::installentry",
    unique   => {
      arch   => ["amd64"],
      ver    => ["squeeze","wheezy"],
      os     => ["debian"],
    },
    common => {
      file      => "menu_deploy",
      kernel    => "images/<%= os %>/<%= ver %>/<%= arch %>/linux",
      append    => "initrd=images/<%= os %>/<%= ver %>/<%= arch %>/initrd.gz auto locale=en_US console-keymaps-at/keymap=us hostname=<%= os %> domain=<%= domain %> url=http://boot.<%= domain %>/d-i/debian_ops.cfg text suite=<%= ver %>",
      menutitle => "Operations auto-deployment <%= os %> <%= ver %> <%= arch %>",
    },
  }

}
