# File::      <tt>mysql-client.pp</tt>
# Author::    Sebastien Varrette (Sebastien.Varrette@uni.lu)
# Copyright:: Copyright (c) 2011 Sebastien Varrette
# License::   GPLv3
#
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
        ensure => $mysql::client::ensure,
        name   => $mysql::params::client_packagename,
    }

}
