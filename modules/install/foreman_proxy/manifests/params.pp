class foreman_proxy::params {
  # variables
  $dir  = '/usr/share/foreman-proxy'
  $user = 'foreman-proxy'
  $log  = '/var/log/foreman-proxy/proxy.log'

  # puppetca settings
  $puppetca          = false
  $autosign_location = '/etc/puppet/autosign.conf'
  $puppetca_cmd      = '/usr/sbin/puppet cert'
  $puppet_group      = 'puppet'

  # puppetrun settings
  $puppetrun     = true
  $puppetrun_cmd = '/usr/sbin/puppetrun'

  # TFTP settings
  # require 'tftp'  # ensures we can access tftp module parameters
  $tftp           = false
  # $syslinux_root  = '/usr/share/syslinux'
  $syslinux_files = ['pxelinux.0','menu.c32','chain.c32']
  # $tftproot       = $tftp::params::root
  $tftp_dir       = ["${tftproot}/pxelinux.cfg","${tftproot}/boot"]

  $dhcp = false
  $dns  = false

}
