# File::      <tt>mysql-client.pp</tt>
# Author::    Sebastien Varrette (Sebastien.Varrette@uni.lu)
# Copyright:: Copyright (c) 2011 Sebastien Varrette
# License::   GPLv3
#
# ------------------------------------------------------------------------------
# = Class: mysql::client
#
# Configure and manage MySQL client utilities such as mysqldump, mysqladmin, the
# "mysql" interactive shell, etc.
#
# == Parameters:
#
# $ensure:: *Default*: 'present'. Ensure the presence (or absence) of mysql::client
#
# == Requires:
#
# n/a
#
# == Sample Usage:
#
#     import mysql::client
#
# You can then specialize the various aspects of the configuration,
# for instance:
#
#         class { 'mysql::client':
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
class mysql::client( $ensure = $mysql::params::ensure ) inherits mysql::params
{
    info ("Configuring mysql::client (with ensure = ${ensure})")

    if ! ($ensure in [ 'present', 'absent' ]) {
        fail("mysql::client 'ensure' parameter must be set to either 'absent' or 'present'")
    }

    case $::operatingsystem {
        debian, ubuntu:         { include mysql::client::debian }
        redhat, fedora, centos: { include mysql::client::redhat }
        default: {
            fail("Module $module_name is not supported on $operatingsystem")
        }
    }
}

# ------------------------------------------------------------------------------
# = Class: mysql::client::common
#
# Base class to be inherited by the other mysql::client classes
#
# Note: respect the Naming standard provided here[http://projects.puppetlabs.com/projects/puppet/wiki/Module_Standards]
class mysql::client::common {

    # Load the variables used in this module. Check the mysql::client-params.pp file
    require mysql::params

    package { 'mysql-client':
        name    => "${mysql::client::params::packagename}",
        ensure  => "${mysql::client::ensure}",
    }
    
}


# ------------------------------------------------------------------------------
# = Class: mysql::client::debian
#
# Specialization class for Debian systems
class mysql::client::debian inherits mysql::client::common { }

# ------------------------------------------------------------------------------
# = Class: mysql::client::redhat
#
# Specialization class for Redhat systems
class mysql::client::redhat inherits mysql::client::common { }



