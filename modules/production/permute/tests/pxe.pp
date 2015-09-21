include pxe

permute { "Debian Ops":
  resource => "pxe::images",
  unique   => {
    arch   => ["amd64"],
    ver    => ["squeeze","wheezy"],
    os     => ["debian"],
  },
  common => {
    baseurl => "http://mirrors.kernel.org/fedora/releases/<%= ver %>/Fedora/<%= arch %>/os/images/pxe/boot/",
  },
}
