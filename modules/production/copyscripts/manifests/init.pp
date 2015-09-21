class copyscripts {
        file { "/usr/local/bin":
                ensure => "directory",
                recurse => true,
                backup => false,
                mode => "755",
                source => "puppet:///files/scripts/",
        }
}
