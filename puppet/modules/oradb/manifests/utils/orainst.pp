# == define: oradb::utils::orainst
#
#  creates oraInst.loc for oracle products
#
#
##
define oradb::utils::orainst
(
  $ora_inventory_dir = undef,
  $os_group          = undef,
)
{
  case $::kernel {
    'Linux': {
      $oraInstPath        = "/etc"
    }
    'SunOS': {
      $oraInstPath        = "/var/opt/oracle"
      if !defined(File[$oraInstPath]) {
        file { $oraInstPath:
          ensure  => directory,
          before  => File["${oraInstPath}/oraInst.loc"],  
        }
      }  
    }
  }

  if !defined(File["${oraInstPath}/oraInst.loc"]) {
    file { "${oraInstPath}/oraInst.loc":
      ensure  => present,
      content => template("oradb/oraInst.loc.erb"),
    }
  }
}
