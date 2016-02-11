# File::      <tt>mysql-params.pp</tt>
# Author::    Sebastien Varrette (Sebastien.Varrette@uni.lu)
# Copyright:: Copyright (c) 2011 Sebastien Varrette
# License::   GPL v3
#
# ------------------------------------------------------------------------------
# = Class: mysql::params
#
# In this class are defined as variables values that are used in other
# mysql classes.
# This class should be included, where necessary, and eventually be enhanced
# with support for more OS
#
# == Warnings
#
# /!\ Always respect the style guide available
# here[http://docs.puppetlabs.com/guides/style_guide]
#
# The usage of a dedicated param classe is advised to better deal with
# parametrized classes, see
# http://docs.puppetlabs.com/guides/parameterized_classes.html
#
# [Remember: No empty lines between comments and class definition]
#
class mysql::params {

    ######## DEFAULTS FOR VARIABLES USERS CAN SET ##########################
    # (Here are set the defaults, provide your custom variables externally)
    # (The default used is in the line with '')
    ###########################################

    # ensure the presence (or absence) of mysql
    $ensure = $mysql_ensure ? {
        ''      => 'present',
        default => "${mysql_ensure}"
    }

    # The Protocol used. Used by monitor and firewall class. Default is 'tcp'
    $protocol = $mysql_protocol ? {
        ''      => 'tcp',
        default => "${mysql_protocol}",
    }
    # The port number. Used by monitor and firewall class. The default is 3306.
    $port = $mysql_port ? {
        ''      => 3306,
        default => "${mysql_port}",
    }

    # The MySQL root password (generated randomly by default)
    $root_password = $mysql_root_password ? {
        ''      => '',
        default => "${mysql_root_password}",
    }

    # Data directory path, which is used to store all the databases
    $datadir = $mysql_datadir ? {
        ''      => '/var/lib/mysql',
        default => $mysql_datadir,
    }

    # Data directory path, which is used to store all the databases
    $bind_address = $mysql_bind_address ? {
        ''      => '127.0.0.1',
        default => $mysql_bind_address,
    }
    $character_set = $mysql_character_set ? {
        ''      => '',
        default => $mysql_character_set,
    }

    #### MODULE INTERNAL VARIABLES  #########
    # (Modify to adapt to unsupported OSes)
    #######################################
    # Client/server packages
    $client_packagename = $::operatingsystem ? {
        /(?i-mx:ubuntu|debian)/ => 'mysql-client',
        default => 'mysql'
    }
    $server_packagename = $::operatingsystem ? {
        default => 'mysql-server',
    }

    # MySQL service
    $servicename = $::operatingsystem ? {
        /(?i-mx:ubuntu|debian)/ => 'mysql',
        default                 => 'mysqld'
    }
    # used for pattern in a service ressource
    $processname = $::operatingsystem ? {
        /(?i-mx:ubuntu|debian)/ => 'mysql',
        default                 => 'mysqld',
    }
    $hasstatus = $::operatingsystem ? {
        /(?i-mx:ubuntu|debian)/        => false,
        /(?i-mx:centos|fedora|redhat)/ => true,
        default => true,
    }
    $hasrestart = $::operatingsystem ? {
        default => true,
    }

    # MySQL Configuration file
    $configfile = $::operatingsystem ? {
        /(?i-mx:ubuntu|debian)/ => '/etc/mysql/my.cnf',
        default => '/etc/my.cnf',
    }
    $configfile_mode = $::operatingsystem ? {
        default => '0644',
    }
    $configfile_owner = $::operatingsystem ? {
        default => 'root',
    }
    $configfile_group = $::operatingsystem ? {
        default => 'root',
    }
    $configfile_seltype = $::operatingsystem ? {
        /(?i-mx:centos|fedora|redhat)/ => 'mysqld_etc_t',
        default => undef,
    }

    # MySQL log directory
    $logdir = $::operatingsystem ? {
        default => '/var/log/mysql',
    }
    $logdir_mode = $::operatingsystem ? {
        default => '2750',
    }
    $logdir_owner = $::operatingsystem ? {
        default => 'mysql',
    }
    $logdir_group = $::operatingsystem ? {
        default => 'adm',
    }
    $logdir_seltype = $::operatingsystem ? {
        /(?i-mx:centos|fedora|redhat)/ => 'mysqld_log_t',
        default => undef,
    }

    # MySQL data directory
    $datadir_mode = $::operatingsystem ? {
        default => '0700',
    }
    $datadir_owner = $::operatingsystem ? {
        default => 'mysql',
    }
    $datadir_group = $::operatingsystem ? {
        default => 'mysql',
    }
    $datadir_seltype = $::operatingsystem ? {
        /(?i-mx:centos|fedora|redhat)/ => 'mysqld_db_t',
        default => undef,
    }

    $root_accessfile = $::operatingsystem ? {
        default => '/root/.my.cnf'
    }

    # MySQL client command (for batch mode)
    $mysql_client_cmd = $::operatingsystem ? {
        #/(?i-mx:ubuntu|debian)/ => "mysql --defaults-file=/etc/mysql/debian.cnf",
        default => "mysql"
    }




    $configdir = $::operatingsystem ? {
        default => "/etc/mysql/conf.d",
    }
    # $configdir_mode = $::operatingsystem ? {
    #     default => '0755',
    # }

    # $configdir_owner = $::operatingsystem ? {
    #     default => 'root',
    # }

    # $configdir_group = $::operatingsystem ? {
    #     default => 'root',
    # }

    # $pkgmanager = $::operatingsystem ? {
    #     /(?i-mx:ubuntu|debian)/          => [ '/usr/bin/apt-get' ],
    #     /(?i-mx:centos|fedora|redhat)/ => [ '/bin/rpm', '/usr/bin/up2date', '/usr/bin/yum' ],
    #     default => []
    # }


}

