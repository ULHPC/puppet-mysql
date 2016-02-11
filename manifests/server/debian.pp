# File::      <tt>mysql-server.pp</tt>
# Author::    Sebastien Varrette (Sebastien.Varrette@uni.lu)
# Copyright:: Copyright (c) 2011 Sebastien Varrette
# License::   GPLv3
#
# ------------------------------------------------------------------------------
# = Class: mysql::server::debian
#
# Specialization class for Debian systems
class mysql::server::debian inherits mysql::server::common {
    Mysql_database { defaults => '/etc/mysql/debian.cnf' }
    #Mysql_user     { defaults => "/etc/mysql/debian.cnf" }
    Mysql_grant    { defaults => '/etc/mysql/debian.cnf' }

    # Delete MySQL users root@${fqdn} and root@127.0.0.1, created by the
    # debian package and left without password
    mysql::user { [ 'root@127.0.0.1', "root@${::fqdn}" ]:
        ensure => 'absent'
    }
}
