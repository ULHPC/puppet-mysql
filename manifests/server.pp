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
    $bind_address    = $mysql::params::bind_address,
    $character_set   = $mysql::params::character_set
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
            fail("Module ${::module_name} is not supported on ${::operatingsystem}")
        }
    }
}
