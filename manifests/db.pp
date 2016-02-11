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
#   on the database). Note that this user will receive the name of the database,
#   unless the $username directive is set.
#
# [*username*]
#   Name of the user to be created, default to $name. (in practice, the real
#   MySQL user created will be ${username}@${host})
#
# [*host*]
#  The host from which this user is assumed to connect from.
#  Default to localhost
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
# [*owner*]
#   Owner of the access file
#
# [*group*]
#   group owner of the access file
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
    $host         = 'localhost',
    $creates_user = false,
    $username     = '',
    $password     = '',
    $ro_password  = '',
    $accessfile   = '',
    $owner        = 'root',
    $group        = 'root'
)
{
    include mysql::params

    # $name is provided by define invocation and is should be set to the name of
    # the database
    $dbname = $name
    $dbuser = $username ? {
        '' => $name,
        default => $username
    }
    $ro_dbuser = "${dbuser}_ro"
    
    info ("Configuring the MySQL DB ${dbname} (with ensure = ${ensure})")

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
    # This is the user to eventually create
    $dbusername = "${dbuser}@${host}"

    # Creates or drop the DB
    case $ensure {
        'present': {
            $action = 'create'
            $db_command = "CREATE DATABASE IF NOT EXISTS ${dbname}; FLUSH PRIVILEGES;"
        }
        'absent': {
            $action = 'drop'
            $db_command = "DROP DATABASE IF EXISTS ${dbname}"
        }
        default: { err ( "Unknown ensure value: '${ensure}'" ) }
    }

    mysql::command { "${action} the MySQL database ${dbname}":
        command => $db_command
    }

    # Eventually creates the associated user and grants him full priviledges on
    # the created database
    if ($creates_user) {

        notice("create MySQL user ${dbusername} with password ${password}")
        if ! defined(Mysql::User [$dbusername]) {
            mysql::user { $dbusername:
                ensure     => $ensure,
                password   => $password,
                accessfile => $accessfile,
                owner      => $owner,
                group      => $group,
                require    => Mysql::Command["${action} the MySQL database ${dbname}"]
                #Mysql_database["${dbname}"],
                #                defaults      => "/root/.my.cnf"
            }
        }

        mysql::command { "Grant ${dbusername} admin of the ${dbname} DB":
            command => "GRANT ALL PRIVILEGES on ${dbname}.* TO ${dbusername}; FLUSH PRIVILEGES;",
            require => Mysql::User[$dbusername],
        }

        if ($ro_password != '') {
            
            case $ensure {
                present: {
                    $rouser_db_cmd = "GRANT SELECT ON ${dbname}.* to '${dbname}_ro'@'localhost'  identified by '${ro_password}'; FLUSH PRIVILEGES;"
                }
                absent: {
                    $rouser_db_cmd = "DROP USER '${dbname}_ro'@'localhost'"
                }
                default: { }
            }
            
            mysql::command { "${action} RO user for ${dbname} DB":
                command => $rouser_db_cmd,
                require => Mysql::Command["${action} the MySQL database ${dbname}"]
            }
            
        }
        
        
        # mysql_grant { "${dbusername}/${dbname}":
        #     privileges => [
        #                    "select_priv", "insert_priv", "update_priv", "delete_priv",
        #                    "create_priv", "drop_priv", "index_priv", "alter_priv",
        #                    "alter_routine_priv", "create_routine_priv", "execute_priv",
        #                    "lock_tables_priv", "references_priv", "show_view_priv"
        #                    ],
        #     require    => Mysql::User["${dbusername}"],
        # }
    }

}






