-*- mode: markdown; mode: visual-line;  -*-

# Mysql Puppet Module 

[![Puppet Forge](http://img.shields.io/puppetforge/v/ULHPC/mysql.svg)](https://forge.puppetlabs.com/ULHPC/mysql)
[![License](http://img.shields.io/:license-GPL3.0-blue.svg)](LICENSE)
![Supported Platforms](http://img.shields.io/badge/platform-debian-lightgrey.svg)
[![Documentation Status](https://readthedocs.org/projects/ulhpc-puppet-mysql/badge/?version=latest)](https://readthedocs.org/projects/ulhpc-puppet-mysql/?badge=latest)

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

## Overview and Usage

### Class `mysql`

This is the main class defined in this module.
It accepts the following parameters: 

* `$ensure`: default to 'present', can be 'absent'

Use it as follows:

     include ' mysql'

See also [`tests/init.pp`](tests/init.pp)

### Class `mysql::client`

See [`tests/client.pp`](tests/client.pp)
### Class `mysql::client::debian`

See [`tests/client/debian.pp`](tests/client/debian.pp)
### Class `mysql::client::redhat`

See [`tests/client/redhat.pp`](tests/client/redhat.pp)
### Class `mysql::server`

See [`tests/server.pp`](tests/server.pp)
### Class `mysql::server::debian`

See [`tests/server/debian.pp`](tests/server/debian.pp)
### Class `mysql::server::redhat`

See [`tests/server/redhat.pp`](tests/server/redhat.pp)

### Definition `mysql::command`

The definition `mysql::command` provides ...
This definition accepts the following parameters:

* `$ensure`: default to 'present', can be 'absent'
* `$content`: specify the contents of the directive as a string
* `$source`: copy a file as the content of the directive.

Example:

        mysql::command { 'toto':
		      ensure => 'present',
        }

See also [`tests/command.pp`](tests/command.pp)

### Definition `mysql::db`

The definition `mysql::db` provides ...
This definition accepts the following parameters:

* `$ensure`: default to 'present', can be 'absent'
* `$content`: specify the contents of the directive as a string
* `$source`: copy a file as the content of the directive.

Example:

        mysql::db { 'toto':
		      ensure => 'present',
        }

See also [`tests/db.pp`](tests/db.pp)

### Definition `mysql::user`

The definition `mysql::user` provides ...
This definition accepts the following parameters:

* `$ensure`: default to 'present', can be 'absent'
* `$content`: specify the contents of the directive as a string
* `$source`: copy a file as the content of the directive.

Example:

        mysql::user { 'toto':
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
