-*- mode: markdown; mode: visual-line;  -*-

# Mysql Puppet Module 

[![Puppet Forge](http://img.shields.io/puppetforge/v/ULHPC/mysql.svg)](https://forge.puppetlabs.com/ULHPC/mysql)
[![License](http://img.shields.io/:license-GPL3.0-blue.svg)](LICENSE)
![Supported Platforms](http://img.shields.io/badge/platform-debian|centos-lightgrey.svg)
[![Documentation Status](https://readthedocs.org/projects/ulhpc-puppet-mysql/badge/?version=latest)](https://readthedocs.org/projects/ulhpc-puppet-mysql/?badge=latest)
[![By ULHPC](https://img.shields.io/badge/by-ULHPC-blue.svg)](http://hpc.uni.lu)

Configure and manage MySQL

      Copyright (c) 2016 S. Varrette, H. Cartiaux, V. Plugaru, S. Diehl aka. UL HPC Management Team <hpc-sysadmins@uni.lu>
      

| [Project Page](https://github.com/ULHPC/puppet-mysql) | [Sources](https://github.com/ULHPC/puppet-mysql) | [Documentation](https://ulhpc-puppet-mysql.readthedocs.org/en/latest/) | [Issues](https://github.com/ULHPC/puppet-mysql/issues) |

## Synopsis

Configure and manage MySQL.

This module implements the following elements: 

* __Puppet classes__:
    - `mysql` 
    - `mysql::client` 
    - `mysql::client::common` 
    - `mysql::client::debian` 
    - `mysql::client::redhat` 
    - `mysql::params` 
    - `mysql::server` 
    - `mysql::server::common` 
    - `mysql::server::debian` 
    - `mysql::server::redhat` 

* __Puppet definitions__: 
    - `mysql::command` 
    - `mysql::db` 
    - `mysql::user` 

All these components are configured through a set of variables you will find in
[`manifests/params.pp`](manifests/params.pp). 

_Note_: the various operations that can be conducted from this repository are piloted from a [`Rakefile`](https://github.com/ruby/rake) and assumes you have a running [Ruby](https://www.ruby-lang.org/en/) installation.
See `docs/contributing.md` for more details on the steps you shall follow to have this `Rakefile` working properly. 

## Dependencies

See [`metadata.json`](metadata.json). In particular, this module depends on 

* [puppetlabs/stdlib](https://forge.puppetlabs.com/puppetlabs/stdlib)

The `pwgen` utility needs to be installed on the Puppetmaster, if the `mysql::server` class should auto-generate the root password.


## Overview and Usage

### Class `mysql`

This is the main class defined in this module.

Use it as follows:

     include 'mysql'

See also [`tests/init.pp`](tests/init.pp)

### Class `mysql::client`

This class installs the MySQL client.

It accepts the following parameters:

* `$ensure`: Default to 'present', can be 'absent'.

This class will automatically include the appropriate specialisation class `mysql::client::debian` or `mysql::client::redhat` based on the OS.

Sample usage:

     import mysql::client

You can then specialize the various aspects of the configuration,
for instance:

         class { 'mysql::client':
             ensure => 'present'
         }


See [`tests/client.pp`](tests/client.pp)

### Class `mysql::server`

This class installs and configures a MySQL server.

This class accepts the following parameters:

* `$ensure`: *Default*: 'present'. Ensure the presence (or absence) of `mysql::server`.

* `$root_password`: *Default*: ''. MySQL root password (left empty for having a random generated one that will be stored in the file `/root/.my.cnf`).

* `$root_accessfile`: *Default*: '/root/.my.cnf'. Configuration file path for 'root' user (containing access details).

* `$datadir`: *Default*: '/var/lib/mysql'. MySQL data directory.

* `$bind_address`: *Default*: '127.0.0.1'. The network service will listen on the specified address.

* `$character_set`: *Default*: ''. Sets MySQL's character set.

This class will automatically include the appropriate specialisation class `mysql::server::debian` or `mysql::server::redhat` based on the OS.

Sample usage:

     import mysql::server
     
You can then specialize the various aspects of the configuration,
for instance:

         class { 'mysql::server':
             ensure => 'present'
         }

See [`tests/server.pp`](tests/server.pp)

### Definition `mysql::command`

The definition `mysql::command` executes a MySQL command (as root user).

This definition accepts the following parameters:


* `$ensure`: Default to 'present', can be 'absent'.

* `$command`: If set, detail the MySQL command to execute.

* `$onlyif`: If this parameter is set, then the MySQL command will only run if the command specified in the onlyif directive returns 0.

* `$unless`: If this parameter is set, then the MySQL command will run unless the command specified in the unless directive returns 0.

* `$mysql_unless`: Specify SQL clause as 'unless' parameter.

* `$mysql_onlyif`: Specify SQL clause as 'onlyif' parameter.


Example:

      mysql::command { "create MySQL database ${dbname}":
          command => "CREATE DATABASE IF NOT EXISTS ${dbname}"
      }

See also [`tests/command.pp`](tests/command.pp)

### Definition `mysql::db`

The definition `mysql::db` sets up a MySQL database (and eventually the dedidated user associated to it).

This definition accepts the following parameters:

* `$ensure`: Default to 'present', can be 'absent'  (BEWARE: it will remove the associated database and ALL its content).

* `$creates_user`: Whether or not to create an associated user (that will have the full rights on the database). Note that this user will receive the name of the database, unless the `$username` directive is set. 

* `$username`: Name of the user to be created, default to `$name` (in practice, the real MySQL user created will be ${username}@${host}).

* `$host`: The host from which this user is assumed to connect from. Default to localhost.

* `$password`: Password of the user to be created. If left to an empty string, a random password will be generated (and stored in accessfile). Details of the user (included the password) will be stored in the file `/root/.my.cnf`.

* `$ro_password`: Password for read-only user.

* `$accessfile`: The file used to save the access configuration for the created user. Default to /root/.my_\<dbname\>.cnf such that later on, you can connect to the  mysql client by issuing `mysql --defaults-file=/root/.my_<dbname>.cnf`.

* `$owner`: Owner of the accessfile.

* `$group`: Group owner of the accessfile.

Example:

      mysql::db { 'mediawiki':
          ensure       => 'present',
          creates_user => true,
       }

See also [`tests/db.pp`](tests/db.pp)

### Definition `mysql::user`

The definition `mysql::user` sets up a MySQL user (and stores the associated password in a file).

This definition accepts the following parameters:

* `$ensure`: Default to 'present', can be 'absent'.

* `$host`: The host from which this user is assumed to connect from. Default to localhost.

* `$password`: Password of the user to be created. If left to an empty string, a random password will be generated (and stored in accessfile). Details of the user (included the password) will be stored in the file \<accessfile\> (see below).

* `$accessfile`: The file used to save the access configuration for the created user. Default to /root/.my_\<dbname\>.cnf such that later on, you can connect to the mysql client by issuing `mysql --defaults-file=/root/.my_<dbname>.cnf`.

* `$owner`: Owner of the access file.

* `$group`: Group owner of the access file.

Example:

	mysql::user { 'mediawiki@localhost':
        ensure => 'present',
    }

See also [`tests/user.pp`](tests/user.pp)


## Librarian-Puppet / R10K Setup

You can of course configure the mysql module in your `Puppetfile` to make it available with [Librarian puppet](http://librarian-puppet.com/) or
[r10k](https://github.com/adrienthebo/r10k) by adding the following entry:

     # Modules from the Puppet Forge
     mod "ULHPC/mysql"

or, if you prefer to work on the git version: 

     mod "ULHPC/mysql", 
         :git => 'https://github.com/ULHPC/puppet-mysql',
         :ref => 'production' 

## Issues / Feature request

You can submit bug / issues / feature request using the [ULHPC/mysql Puppet Module Tracker](https://github.com/ULHPC/puppet-mysql/issues). 

## Developments / Contributing to the code 

If you want to contribute to the code, you shall be aware of the way this module is organized. 
These elements are detailed on [`docs/contributing.md`](contributing/index.md).

You are more than welcome to contribute to its development by [sending a pull request](https://help.github.com/articles/using-pull-requests). 

## Puppet modules tests within a Vagrant box

The best way to test this module in a non-intrusive way is to rely on [Vagrant](http://www.vagrantup.com/).
The `Vagrantfile` at the root of the repository pilot the provisioning various vagrant boxes available on [Vagrant cloud](https://atlas.hashicorp.com/boxes/search?utf8=%E2%9C%93&sort=&provider=virtualbox&q=svarrette) you can use to test this module.

See [`docs/vagrant.md`](vagrant.md) for more details. 

## Online Documentation

[Read the Docs](https://readthedocs.org/) aka RTFD hosts documentation for the open source community and the [ULHPC/mysql](https://github.com/ULHPC/puppet-mysql) puppet module has its documentation (see the `docs/` directly) hosted on [readthedocs](http://ulhpc-puppet-mysql.rtfd.org).

See [`docs/rtfd.md`](rtfd.md) for more details.

## Licence

This project and the sources proposed within this repository are released under the terms of the [GPL-3.0](LICENCE) licence.


[![Licence](https://www.gnu.org/graphics/gplv3-88x31.png)](LICENSE)
