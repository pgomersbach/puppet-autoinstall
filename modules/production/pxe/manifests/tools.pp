class pxe::tools {

  $tftp_root = $::pxe::tftp_root

  # Create the directory to store all the tool images
  file { "${tftp_root}/tools}":
    ensure  => directory,
    require => Class[tftp],
  }

  # Create the tool menu
  pxe::menu { "Tools":
    file => "menu_tools",
    require => File[ "${tftp_root}/tools}" ],
  }

  file { "${tftp_root}/tools":
    ensure => directory,
  }

  # Bring in some tools
  include pxe::tools::memtest

}
