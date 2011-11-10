# File::      <tt>mysql-db.pp</tt>
# Author::    Sebastien Varrette (<Sebastien.Varrette@uni.lu>)
# Copyright:: Copyright (c) 2011 Sebastien Varrette (www[http://varrette.gforge.uni.lu])
# License::   GPLv3
#
# ------------------------------------------------------------------------------
# = Defines: mysql::db
#
# Setup a MySQL database (and eventually the dedidated user associated to it)
#
# == Parameters:
#
# [*ensure*]
#   default to 'present', can be 'absent' (BEWARE: it will remove the associated
#   database and ALL its content)
#   Default: 'present'
#
# [*creates_user*]
#   Whether or not to create an associated user (that will have the full rights
#   on the database). Note that this user will receive the name of teh database
#
# [*password*]
#   password of the user to be created. If left to an empty string, a random
#   password will be generated (and stored in accessfile)
#   Details of the user (included the password) will be stored in the file
#   /root/.my.cnf
#
# [*accessfile*]
#   The file used to save the access configuration for the created user.
#   Default to /root/.my_<dbname>.cnf such that later on, you can connect to the
#   mysql client by issuing  'mysql --defaults-file=/root/.my_<dbname>.cnf'
#
# == Requires:
#
# The class mysql::server should have been instanciated.
#
# == Sample usage:
#
#      mysql::db { 'mediawiki':
#          ensure       => 'present',
#          creates_user => true,
#      }
#
# == Warnings
#
# /!\ Always respect the style guide available
# here[http://docs.puppetlabs.com/guides/style_guide]
#
# [Remember: No empty lines between comments and class definition]
#
define mysql::db (
    $ensure       = 'present',
    $creates_user = true,
    $password     = '',
    $accessfile   = ''
)
{
    include mysql::params

    # $name is provided by define invocation and is should be set to the name of
    # the database
    $dbname = $name
    $dbuser = $name

    info ("Configuring the MySQL DB ${dbname} (with ensure = ${ensure}")

    if (! defined( Class['mysql::server'] ) ) {
        fail("The class 'mysql::server' is not instancied")
    }

    if ! ($ensure in [ 'present', 'absent' ]) {
        fail("mysql::db 'ensure' parameter must be set to either 'absent' or 'present'")
    }
    if ($mysql::server::ensure != $ensure) {
        if ($mysql::server::ensure != 'present') {
            fail("Cannot create the database '${dbname}' as mysql::server::ensure is NOT set to present (but ${mysql::server::ensure})")
        }
    }

    # Creates the DB
    mysql_database { "${dbname}":
        ensure   => $ensure,
        require  => Class['mysql::server'], #File["/root/.my.cnf"],
        #        defaults => '/root/.my.cnf',
    }

    # Eventually creates the associated user and grants him full priviledges on
    # the created database
    if ($creates_user and $ensure == 'present') {
        # This is the user to create
        $dbusername = "${dbuser}@localhost"

        if ! defined(Mysql::User ["${dbusername}"]) {
            mysql::user { "${dbusername}":
                password => "${dbuser_passwd}",
                require  => Mysql_database["${dbname}"],
                #                defaults      => "/root/.my.cnf"
            }
        }

        mysql_grant { "${dbusername}/${dbname}":
            privileges => [
                           "select_priv", "insert_priv", "update_priv", "delete_priv",
                           "create_priv", "drop_priv", "index_priv", "alter_priv",
                           "alter_routine_priv", "create_routine_priv", "execute_priv",
                           "lock_tables_priv", "references_priv", "show_view_priv"
                           ],
            require    => Mysql::User["${dbusername}"],
        }

    }

}






