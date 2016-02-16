# File::      <tt>server.pp</tt>
# Author::    S. Varrette, H. Cartiaux, V. Plugaru, S. Diehl aka. UL HPC Management Team (hpc-sysadmins@uni.lu)
# Copyright:: Copyright (c) 2016 S. Varrette, H. Cartiaux, V. Plugaru, S. Diehl aka. UL HPC Management Team
# License::   Gpl-3.0
#
# ------------------------------------------------------------------------------

node default {
  # pwgen needs to be installed, but dependency does not seem to work
  
  package {'pwgen':
    ensure => 'present',
  } ->

  class { 'mysql::server':
    ensure => 'present',
  }
}
