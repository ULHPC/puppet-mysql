# File::      <tt>mysql-command.pp</tt>
# Author::    Sebastien Varrette (<Sebastien.Varrette@uni.lu>)
# Copyright:: Copyright (c) 2011 Sebastien Varrette (www[http://varrette.gforge.uni.lu])
# License::   GPLv3
#
# ------------------------------------------------------------------------------
# = Defines: mysql::command
#
# Execute a MySQL command (as root user)
#
# == Parameters:
#
# [*command*]
#  If set, detail the MySQL command to execute
#
# [*onlyif*]
#  If this parameter is set, then the MySQL command will only run if the command
#  specified in the onlyif directive returns 0
#
# [*unless*]
#  If this parameter is set, then the MySQL command will run unless the command
#  specified in the unless directive returns 0.
#
# == Requires:
#
# The class mysql::server should have been instanciated.
#
# == Sample usage:
#
#      mysql::command { "create MySQL database ${dbname}":
#          command => "CREATE DATABASE IF NOT EXISTS ${dbname}"
#      }
#
# == Warnings
#
# /!\ Always respect the style guide available
# here[http://docs.puppetlabs.com/guides/style_guide]
#
# [Remember: No empty lines between comments and class definition]
#
define mysql::command (
    $ensure  = 'present',
    $command = '',
    $onlyif  = undef,
    $unless  = undef
)
{
    include mysql::params

    # $name is provided by define invocation and is typically set to the command
    # to operate
    $cmd = $command ? {
        ''      => "${name}",
        default => "${command}"
    }

    # If we want to operate the MySQL command as root user (from the MySQL
    # server point of view), we have to connect via the client interface and the
    # accessfile created by mysql::server
    $mysql_cmd = "${mysql::params::mysql_client_cmd} --defaults-file=${mysql::params::root_accessfile}"

    if ! ($ensure in [ 'present', 'absent' ]) {
        fail("mysql::command 'ensure' parameter must be set to either 'absent' or 'present'")
    }
    if (! defined( Class['mysql::server'] ) ) {
        fail("The class 'mysql::server' is not instancied")
    }

    if ($ensure == 'present') {
        # Now execute the command:
        exec { "${name}":
            command => "${mysql_cmd} -NBe \"${cmd}\"",
            path    => '/sbin:/usr/bin:/usr/sbin:/bin',
            user    => 'root',
            onlyif  => $onlyif,
            unless  => $unless,
            require =>  [
                         Class['mysql::client'],
                         Class['mysql::server'],
                         File["/root/.my.cnf"],
                         ]
        }
    }
}






