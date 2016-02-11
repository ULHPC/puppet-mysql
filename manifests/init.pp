# File::      init.pp
# Author::    Sarah Diehl (Sarah.Diehl@uni.lu)
# Copyright:: Copyright (c) 2016 Sarah Diehl
# License::   GPLv3
#
# ------------------------------------------------------------------------------

class mysql inherits mysql::params {
  contain mysql::server
  contain mysql::client
}
