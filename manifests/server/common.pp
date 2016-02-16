# File::      <tt>mysql-server.pp</tt>
# Author::    Sebastien Varrette (Sebastien.Varrette@uni.lu)
# Copyright:: Copyright (c) 2011 Sebastien Varrette
# License::   GPLv3
#
# ------------------------------------------------------------------------------
# = Class: mysql::server::common
#
# Base class to be inherited by the other mysql::server classes
#
# Note: respect the Naming standard provided here[http://projects.puppetlabs.com/projects/puppet/wiki/Module_Standards]
class mysql::server::common {

    # Load the variables used in this module. Check the mysql::server-params.pp file
    require mysql::params

    package { 'mysql-server':
        ensure => $mysql::server::ensure,
        name   => $mysql::params::server_packagename,
    }

    if (defined(Class['apache']) and $apache::use_php == true) {
        if !defined(Package['php5-mysql']) {
            package { 'php5-mysql':
                ensure  => $mysql::server::ensure,
            }
        }
    }

    # MySQL user and group
    user { 'mysql':
        ensure  => $mysql::server::ensure,
        require => Package['mysql-server'],
        shell   => '/bin/false'
    }
    group { 'mysql':
        ensure  => $mysql::server::ensure,
        require => Package['mysql-server'],
    }

    # Generate the root password
    $root_user = 'root'
    $real_root_password = $mysql::server::root_password ? {
        #''      => random_password('20'),
        # or if pwgen is installed on the puppet server:
        ''     => generate('/usr/bin/pwgen', '--secure', 20, 1),
        default => $mysql::server::root_password
    }

    exec { 'Initialize MySQL server root password':
        unless  => "/usr/bin/test -f ${mysql::server::root_accessfile}",
        command => "mysqladmin -u ${root_user} -h localhost password ${real_root_password}",
        path    => "/usr/local/bin:/usr/local/sbin:/bin:/usr/bin:/usr/sbin:/sbin",
        notify  => File[$mysql::server::root_accessfile],
        require => [
                    Package['mysql-server'],
                    Service['mysql-server']
                    ],
        user    => 'root',
        group   => 'root',
    }

    file { $mysql::server::root_accessfile:
        ensure  => $mysql::server::ensure,
        owner   => 'root',
        group   => 'root',
        mode    => '0600',
        replace => false,
        content => template('mysql/root_my.cnf.erb'),
        require => Exec['Initialize MySQL server root password'],
    }

    if ($mysql::server::ensure == 'present') {

        # Data dir
        file { $mysql::server::datadir:
            ensure  => 'directory',
            owner   => $mysql::params::datadir_owner,
            group   => $mysql::params::datadir_group,
            mode    => $mysql::params::datadir_mode,
            seltype => $mysql::params::datadir_seltype,
            require => Package['mysql-server'],
        }

        # If set, copies the content of the default mysql data location. This is
        # necessary on Debian systems because the package installation script
        # creates a special user used by the init scripts.
        if( $mysql::server::datadir != '/var/lib/mysql' ) {
            File[$mysql::server::datadir] {
                source  => '/var/lib/mysql',
                recurse => true,
                replace => false,
            }
        }

        if ($mysql::server::bind_address != '127.0.0.1') {
            augeas { "/files${mysql::params::configfile}":
                changes => "set /files${mysql::params::configfile}/*/bind-address '${mysql::server::bind_address}'",
                onlyif  => "get /files${mysql::params::configfile}/*/bind-address != '${mysql::server::bind_address}'",
                notify  => Service['mysql-server']
            }
        }

        if ($mysql::server::character_set != '') {
            file { "${mysql::params::configdir}/characterset.conf":
                ensure  => $mysql::server::ensure,
                content => "[mysqld]\n character-set-server=${mysql::server::character_set}",
                require => Package['mysql-server'],
                notify  => Service['mysql-server']
            }
        }
    }
    else
    {
        file { $mysql::server::datadir:
            ensure => $mysql::server::ensure
        }
    }

    service { 'mysql-server':
        ensure     => running,
        name       => $mysql::params::servicename,
        enable     => true,
        hasrestart => $mysql::params::hasrestart,
        pattern    => $mysql::params::processname,
        hasstatus  => $mysql::params::hasstatus,
        require    => Package['mysql-server'],
        #subscribe  => File['mysql-server.conf'],
    }

    # Collect all databases and users
    #Mysql_database<<||>>
    #Mysql_user<<||>>
    #Mysql_grant<<||>>

}
