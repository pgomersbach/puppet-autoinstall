class pxe ($tftp_root='/srv/tftp'){

  include tftp
  include pxe::params
  include pxe::tools
  include pxe::syslinux
}
