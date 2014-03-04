# File::      <tt>mysql-server.pp</tt>
# Author::    Sebastien Varrette (Sebastien.Varrette@uni.lu)
# Copyright:: Copyright (c) 2011 Sebastien Varrette
# License::   GPLv3
#
# ------------------------------------------------------------------------------
# = Class: mysql::server
#
# Configure and manage a MySQL server
#
# == Parameters:
#
# $ensure:: *Default*: 'present'. Ensure the presence (or absence) of mysql::server
# $root_password:: *Default*: ''. MySQL root password (left empty for having a random generated one that will be stored in the file /root/.my.cnf)
# $datadir::  *Default*: '/var/lib/mysql'. MySQL Data directory
# $bind_address::  *Default*: '127.0.0.1'. The network service will listen on the specified address
#
# == Requires:
#
# n/a
#
# == Sample Usage:
#
#     import mysql::server
#
# You can then specialize the various aspects of the configuration,
# for instance:
#
#         class { 'mysql::server':
#             ensure => 'present'
#         }
#
# == Warnings
#
# /!\ Always respect the style guide available
# here[http://docs.puppetlabs.com/guides/style_guide]
#
#
# [Remember: No empty lines between comments and class definition]
#
class mysql::server(
    $ensure          = $mysql::params::ensure,
    $root_password   = $mysql::params::root_password,
    $root_accessfile = $mysql::params::root_accessfile,
    $datadir         = $mysql::params::datadir,
    $bind_address    = $mysql::params::bind_address
)
inherits mysql::client
{
    Class['mysql::server'] -> Class['mysql::client']

    info ("Configuring mysql::server (with ensure = ${ensure})")

    if ! ($ensure in [ 'present', 'absent' ]) {
        fail("mysql::server 'ensure' parameter must be set to either 'absent' or 'present'")
    }

    case $::operatingsystem {
        debian, ubuntu:         { include mysql::server::debian }
        redhat, fedora, centos: { include mysql::server::redhat }
        default: {
            fail("Module $module_name is not supported on $operatingsystem")
        }
    }
}

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
        name    => "${mysql::params::server_packagename}",
        ensure  => "${mysql::server::ensure}",
    }

    if (defined(Class['apache']) and $apache::use_php == true) {
        if !defined(Package['php5-mysql']) {
            package { 'php5-mysql':
                ensure  => "${mysql::server::ensure}",
            }
        }
    }

    # MySQL user and group
    user { 'mysql':
        ensure  => "${mysql::server::ensure}",
        require => Package["mysql-server"],
        shell   => '/bin/false'
    }
    group { 'mysql':
        ensure  => "${mysql::server::ensure}",
        require => Package["mysql-server"],
    }

    # Generate the root password
    $root_user = 'root'
    $real_root_password = $mysql::server::root_password ? {
        #''      => random_password('20'),
        # or if pwgen is installed on the puppet server:
        ''     => generate("/usr/bin/pwgen", '--secure', 20, 1),
        default => "${mysql::server::root_password}"
    }

    exec { "Initialize MySQL server root password":
        unless  => "test -f ${mysql::server::root_accessfile}",
        command => "mysqladmin -u ${root_user} -h localhost password ${real_root_password}",
        notify  => File["${mysql::server::root_accessfile}"],
        require => [
                    Package['mysql-server'],
                    Service['mysql-server']
                    ],
        user    => 'root',
        group   => 'root',
    }

    file { "${mysql::server::root_accessfile}":
        ensure  => "${mysql::server::ensure}",
        owner   => 'root',
        group   => 'root',
        mode    => '0600',
        replace => false,
        content => template("mysql/root_my.cnf.erb"),
        require => Exec["Initialize MySQL server root password"],
    }

    if ($mysql::server::ensure == 'present') {

        # Data dir
        file { "${mysql::server::datadir}":
            ensure  => 'directory',
            owner   => "${mysql::params::datadir_owner}",
            group   => "${mysql::params::datadir_group}",
            mode    => "${mysql::params::datadir_mode}",
            seltype => "${mysql::params::datadir_seltype}",
            require => Package['mysql-server'],
        }

        # If set, copies the content of the default mysql data location. This is
        # necessary on Debian systems because the package installation script
        # creates a special user used by the init scripts.
        if( "${mysql::server::datadir}" != '/var/lib/mysql' ) {
            File["${mysql::server::datadir}"] {
                source  => '/var/lib/mysql',
                recurse => true,
                replace => false,
            }
        }

        if ("${mysql::server::bind_address}" != "127.0.0.1") {
            augeas { "/files${mysql::params::configfile}":
                changes => "set /files${mysql::params::configfile}/*/bind-address '${mysql::server::bind_address}'",
                onlyif  => "get /files${mysql::params::configfile}/*/bind-address != '${mysql::server::bind_address}'",
                notify  => Service['mysql-server']
            }
        }

    }
    else
    {
        file { "${mysql::server::datadir}":
            ensure => "${mysql::server::ensure}"
        }
    }

    service { 'mysql-server':
        name       => "${mysql::params::servicename}",
        enable     => true,
        ensure     => running,
        hasrestart => "${mysql::params::hasrestart}",
        pattern    => "${mysql::params::processname}",
        hasstatus  => "${mysql::params::hasstatus}",
        require    => Package['mysql-server'],
        #subscribe  => File['mysql-server.conf'],
    }

    # Collect all databases and users
    #Mysql_database<<||>>
    #Mysql_user<<||>>
    #Mysql_grant<<||>>

}


# ------------------------------------------------------------------------------
# = Class: mysql::server::debian
#
# Specialization class for Debian systems
class mysql::server::debian inherits mysql::server::common {
    Mysql_database { defaults => "/etc/mysql/debian.cnf" }
    #Mysql_user     { defaults => "/etc/mysql/debian.cnf" }
    Mysql_grant    { defaults => "/etc/mysql/debian.cnf" }

    # Delete MySQL users root@${fqdn} and root@127.0.0.1, created by the
    # debian package and left without password
    mysql::user { [ "root@127.0.0.1", "root@${fqdn}" ]:
        ensure => 'absent'
    }
}

# ------------------------------------------------------------------------------
# = Class: mysql::server::redhat
#
# Specialization class for Redhat systems
class mysql::server::redhat inherits mysql::server::common { }



