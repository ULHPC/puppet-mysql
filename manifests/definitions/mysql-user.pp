# File::      <tt>mysql-user.pp</tt>
# Author::    Sebastien Varrette (<Sebastien.Varrette@uni.lu>)
# Copyright:: Copyright (c) 2011 Sebastien Varrette (www[http://varrette.gforge.uni.lu])
# License::   GPLv3
#
# ------------------------------------------------------------------------------
# = Defines: mysql::user
#
# Setup a MySQL user (and store the associated password in a file)
#
# == Parameters:
#
# [*ensure*]
#   default to 'present', can be 'absent'
#   Default: 'present'
#
# [*password*]
#   password of the user to be created. If left to an empty string, a random
#   password will be generated (and stored in accessfile)
#   Details of the user (included the password) will be stored in the file
#   <accessfile> (see below)
#
# [*host*]
#  The host from which this user is assumed to connect from.
#  Default to localhost
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
#      mysql::user { 'mediawiki@localhost':
#          ensure       => 'present',
#      }
#
# == Warnings
#
# /!\ Always respect the style guide available
# here[http://docs.puppetlabs.com/guides/style_guide]
#
# [Remember: No empty lines between comments and class definition]
#
define mysql::user (
    $ensure        = 'present',
    $host          = '',
    $password      = '',
    $accessfile    = ''
)
{
    include mysql::params

    # $name is provided by define invocation. It is probably of the form
    # user@host.
    $full_username = $name

    $username   = inline_template("<%= name.split('@')[0] %>")
    $userhost   = inline_template("<%= name.split('@')[1] %>")
    $real_host = $userhost ? {
        ''      => $host ? {
            ''      => 'localhost',
            default => "${host}"
        },
        default => "${userhost}"
    }

    # Handle the password
    $userpasswd = $password ? {
        ''      => chomp(generate("/usr/bin/pwgen", '--secure', 20, 1)),
        default => "${password}"
    }
    $hashed_passwd = mysql_password("${userpasswd}")

    $stored_accessfile = $accessfile ? {
        ''      => "/root/.my_${username}.cnf",
        default => "${accessfile}"
    }

    info ("Configuring the MySQL user ${full_username} (with ensure = ${ensure})")

    if (! defined( Class['mysql::server'] ) ) {
        fail("The class 'mysql::server' is not instancied")
    }

    if ! ($ensure in [ 'present', 'absent' ]) {
        fail("mysql::user 'ensure' parameter must be set to either 'absent' or 'present'")
    }
    if ($mysql::server::ensure != $ensure) {
        if ($mysql::server::ensure != 'present') {
            fail("Cannot create the user '${full_username}' as mysql::server::ensure is NOT set to present (but ${mysql::server::ensure})")
        }
    }

    # Creates or drop the user
    case $ensure {
        'present': {
            $action = "create"
            $db_command = "CREATE USER '${username}'@'${real_host}' IDENTIFIED BY PASSWORD '${hashed_passwd}'"
            $cmd_onlyif = undef
            $cmd_unless = "test -f ${stored_accessfile}"

            if ! defined(File["${stored_accessfile}"]) {
                file { "${stored_accessfile}":
                    ensure  => 'file',
                    owner   => 'root',
                    group   => 'root',
                    mode    => '0600',
                    replace => false,
                    content => template("mysql/user_my.cnf.erb"),
                    require => Exec["${action} the MySQL user ${full_username}"]
                }
            }


        }
        'absent': {
            $action = "drop"
            $db_command = "GRANT USAGE ON *.* TO '${username}'@'${real_host}'; DROP USER '${username}'@'${real_host}'; FLUSH PRIVILEGES;"
            $cmd_onlyif = "test -f ${stored_accessfile}"
            $cmd_unless = undef
            if ! defined(File["${stored_accessfile}"]) {
                file { "${stored_accessfile}":
                    ensure => 'absent',
                    require => Exec["${action} the MySQL user ${full_username}"]
                }
            }

        }
        default: { err ( "Unknown ensure value: '${ensure}'" ) }
    }

    mysql::command { "${action} the MySQL user ${full_username}":
        command => "${db_command}",
        onlyif  => $cmd_onlyif,
        unless  => $cmd_unless,
    }

    # # Add (or remove) the access file i.e. /root/.my_${username}.cnf
    # if ! defined(File["${stored_accessfile}"]) {
    #     file { "${stored_accessfile}":
    #         ensure  => "${ensure}",
    #         owner   => 'root',
    #         group   => 'root',
    #         mode    => '0600',
    #         replace => false,
    #         content => template("mysql/user_my.cnf.erb"),
    #         require => Exec["${action} the MySQL user ${full_username}"]
    #     }
    # }

}






