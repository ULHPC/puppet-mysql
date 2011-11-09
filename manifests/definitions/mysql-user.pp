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
#      mysql::user { 'mediawiki':
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
    $password      = '',
    $accessfile    = ''
)
{
    include mysql::params

    # $name is provided by define invocation and is should be set to the name of
    # the database
    $full_username = $name
    $username   = inline_template("<%= name.split('@')[0] %>")
    $host       = inline_template("<%= name.split('@')[1] %>")
    $userpasswd = $password ? {
        ''      => chomp(generate("/usr/bin/pwgen", '--secure', 20, 1)),
        default => $password
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

    # Creates the user
    case $ensure {
        'present': {         
            exec { "create MySQL user ${full_username}":
                command => "${mysql::params::mysql_client_cmd} -NBe \"CREATE USER '${username}'@'${host}' IDENTIFIED BY PASSWORD '${hashed_passwd}'\"",
                path    => '/sbin:/usr/bin:/usr/sbin:/bin',
                user    => 'root',
                unless  => "test -f ${stored_accessfile}",
                require =>  [
                             Class['mysql::client'],
                             Class['mysql::server'],
                             File["/root/.my.cnf"],
                             ]
            }

            # Add the entry in /root/.my_${username}.cnf
            file { "${stored_accessfile}":
                ensure  => "${ensure}",
                owner   => 'root',
                group   => 'root',
                mode    => '0600',
                replace => false,
                content => template("mysql/user_my.cnf.erb"),
                require => Exec["create MySQL user ${full_username}"]
            }
        }

        'absent': {
            exec { "drop MySQL user ${full_username}":
                command => "${mysql::params::mysql_client_cmd} -NBe \"GRANT USAGE ON *.* TO '${username}'@'${host}'; DROP USER '${username}'@'${host}'\"",
                path    => '/sbin:/usr/bin:/usr/sbin:/bin',
                user    => 'root',
                require =>  File["/root/.my.cnf"],
            }

            exec { "delete MySQL access file for ${full_username}":
                command => "rm -f ${stored_accessfile}",
                path    => '/sbin:/usr/bin:/usr/sbin:/bin',
                onlyif  => "test -f ${stored_accessfile}",
                require => Exec["drop MySQL user ${full_username}"]
            }
        }
        default: { err ( "Unknown ensure value: '${ensure}'" ) }
    }

}






