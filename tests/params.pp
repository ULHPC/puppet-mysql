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

$names = ["ensure", "protocol", "port", "packagename"]

notice("mysql::params::ensure = ${mysql::params::ensure}")
notice("mysql::params::protocol = ${mysql::params::protocol}")
notice("mysql::params::port = ${mysql::params::port}")
notice("mysql::params::packagename = ${mysql::params::packagename}")

#each($names) |$v| {
#    $var = "mysql::params::${v}"
#    notice("${var} = ", inline_template('<%= scope.lookupvar(@var) %>'))
#}
