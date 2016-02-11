# File::      <tt>params.pp</tt>
# Author::    S. Varrette, H. Cartiaux, V. Plugaru, S. Diehl aka. UL HPC Management Team (hpc-sysadmins@uni.lu)
# Copyright:: Copyright (c) 2016 S. Varrette, H. Cartiaux, V. Plugaru, S. Diehl aka. UL HPC Management Team
# License::   Gpl-3.0
#
# ------------------------------------------------------------------------------
# You need the 'future' parser to be able to execute this manifest (that's
# required for the each loop below).
#
# Thus execute this manifest in your vagrant box as follows:
#
#      sudo puppet apply -t --parser future /vagrant/tests/params.pp
#
#

include 'mysql::params'

$names = ["ensure", "protocol", "port", "root_password", "datadir", "bind_address", "character_set", "client_packagename", "server_packagename", "servicename", "processname", "hasstatus", "hasrestart", "configfile", "configfile_mode", "configfile_owner", "configfile_group", "configfile_seltype", "logdir", "logdir_mode", "logdir_owner", "logdir_group", "logdir_seltype", "datadir_mode", "datadir_owner", "datadir_group", "datadir_seltype", "root_accessfile", "mysql_client_cmd", "configdir"]

notice("mysql::params::ensure = ${mysql::params::ensure}")
notice("mysql::params::protocol = ${mysql::params::protocol}")
notice("mysql::params::port = ${mysql::params::port}")
notice("mysql::params::root_password = ${mysql::params::root_password}")
notice("mysql::params::datadir = ${mysql::params::datadir}")
notice("mysql::params::bind_address = ${mysql::params::bind_address}")
notice("mysql::params::character_set = ${mysql::params::character_set}")
notice("mysql::params::client_packagename = ${mysql::params::client_packagename}")
notice("mysql::params::server_packagename = ${mysql::params::server_packagename}")
notice("mysql::params::servicename = ${mysql::params::servicename}")
notice("mysql::params::processname = ${mysql::params::processname}")
notice("mysql::params::hasstatus = ${mysql::params::hasstatus}")
notice("mysql::params::hasrestart = ${mysql::params::hasrestart}")
notice("mysql::params::configfile = ${mysql::params::configfile}")
notice("mysql::params::configfile_mode = ${mysql::params::configfile_mode}")
notice("mysql::params::configfile_owner = ${mysql::params::configfile_owner}")
notice("mysql::params::configfile_group = ${mysql::params::configfile_group}")
notice("mysql::params::configfile_seltype = ${mysql::params::configfile_seltype}")
notice("mysql::params::logdir = ${mysql::params::logdir}")
notice("mysql::params::logdir_mode = ${mysql::params::logdir_mode}")
notice("mysql::params::logdir_owner = ${mysql::params::logdir_owner}")
notice("mysql::params::logdir_group = ${mysql::params::logdir_group}")
notice("mysql::params::logdir_seltype = ${mysql::params::logdir_seltype}")
notice("mysql::params::datadir_mode = ${mysql::params::datadir_mode}")
notice("mysql::params::datadir_owner = ${mysql::params::datadir_owner}")
notice("mysql::params::datadir_group = ${mysql::params::datadir_group}")
notice("mysql::params::datadir_seltype = ${mysql::params::datadir_seltype}")
notice("mysql::params::root_accessfile = ${mysql::params::root_accessfile}")
notice("mysql::params::mysql_client_cmd = ${mysql::params::mysql_client_cmd}")
notice("mysql::params::configdir = ${mysql::params::configdir}")

#each($names) |$v| {
#    $var = "mysql::params::${v}"
#    notice("${var} = ", inline_template('<%= scope.lookupvar(@var) %>'))
#}
