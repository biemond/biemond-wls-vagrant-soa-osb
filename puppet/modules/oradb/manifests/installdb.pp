# == Class: oradb::installdb
#
# The databaseType value should contain only one of these choices.
# EE     : Enterprise Edition
# SE     : Standard Edition
# SEONE  : Standard Edition One
#
#
define oradb::installdb( 
  $version                 = undef,
  $file                    = undef,
  $databaseType            = 'SE',
  $oraInventoryDir         = undef,   
  $oracleBase              = undef,
  $oracleHome              = undef,
  $createUser              = true,
  $user                    = 'oracle',
  $userBaseDir             = '/home',
  $group                   = 'dba',
  $group_install           = 'oinstall',
  $group_oper              = 'oper',
  $downloadDir             = '/install',
  $zipExtract              = true,
  $puppetDownloadMntPoint  = undef,
  $remoteFile              = true,
)
{
  # check if the oracle software already exists
  $found = oracle_exists( $oracleHome )

  if $found == undef {
    $continue = true
  } else {
    if ( $found ) {
      $continue = false
    } else {
      notify {"oradb::installdb ${oracleHome} does not exists":}
      $continue = true
    }
  }

  if ( $continue ) {

    $execPath     = "/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:"

    if $puppetDownloadMntPoint == undef {
      $mountPoint     = "puppet:///modules/oradb/"
    } else {
      $mountPoint     = $puppetDownloadMntPoint
    }

    if $oraInventoryDir == undef {
      $oraInventory = "${oracleBase}/oraInventory"
    } else {
      $oraInventory = "${oraInventoryDir}/oraInventory"
    }

    oradb::utils::structure{"oracle structure ${version}":
      oracle_base_home_dir => $oracleBase,
      ora_inventory_dir    => $oraInventory,
      os_user              => $user,
      os_group             => $group,
      os_group_install     => $group_install,
      os_group_oper        => $group_oper,
      download_dir         => $downloadDir,
      log_output           => true,
      user_base_dir        => $userBaseDir,
      create_user          => $createUser,
    }

    if ( $zipExtract ) {
      # In $downloadDir, will Puppet extract the ZIP files or is this a pre-extracted directory structure.

      if ( $version == '11.2.0.1' or $version == '12.1.0.1' ) {
        $file1 =  "${file}_1of2.zip"
        $file2 =  "${file}_2of2.zip"
      } 

      if ( $version == '11.2.0.3' or $version == '11.2.0.4' ) {
        $file1 =  "${file}_1of7.zip"
        $file2 =  "${file}_2of7.zip"
      }

      if $remoteFile == true {

        file { "${downloadDir}/${file1}":
          ensure      => present,
          source      => "${mountPoint}/${file1}",
          mode        => '0775',
          owner       => $user,
          group       => $group,
          require     => Oradb::Utils::Structure["oracle structure ${version}"],
          before      => Exec["extract ${downloadDir}/${file1}"],
        }
        # db file 2 installer zip
        file { "${downloadDir}/${file2}":
          ensure      => present,
          source      => "${mountPoint}/${file2}",
          mode        => '0775',
          owner       => $user,
          group       => $group,
          require     => File["${downloadDir}/${file1}"],
          before      => Exec["extract ${downloadDir}/${file2}"]
        }
        $source = $downloadDir
      } else {
        $source = $mountPoint
      }

      exec { "extract ${downloadDir}/${file1}":
        command     => "unzip -o ${source}/${file1} -d ${downloadDir}/${file}",
        timeout     => 0,
        logoutput   => false,
        path        => $execPath,
        user        => $user,
        group       => $group,
        require     => Oradb::Utils::Structure["oracle structure ${version}"],
        before      => Exec["install oracle database ${title}"],
      }
      exec { "extract ${downloadDir}/${file2}":
        command     => "unzip -o ${source}/${file2} -d ${downloadDir}/${file}",
        timeout     => 0,
        logoutput   => false,
        path        => $execPath,
        user        => $user,
        group       => $group,
        require     => Exec["extract ${downloadDir}/${file1}"],
        before      => Exec["install oracle database ${title}"],
      }
    }

    oradb::utils::orainst{"database orainst ${version}":
      ora_inventory_dir => $oraInventory,
      os_group          => $group_install,
    }

    if ! defined(File["${downloadDir}/db_install_${version}.rsp"]) {
      file { "${downloadDir}/db_install_${version}.rsp":
        ensure        => present,
        content       => template("oradb/db_install_${version}.rsp.erb"),
        mode          => '0775',
        owner         => $user,
        group         => $group,
        require       => Oradb::Utils::Orainst["database orainst ${version}"],
      }
    }

    if ( $version == '11.2.0.1' or 
         $version == '12.1.0.1' or 
         $version == '11.2.0.3' or 
         $version == '11.2.0.4' ) {
      exec { "install oracle database ${title}":
        command     => "/bin/sh -c 'unset DISPLAY;${downloadDir}/${file}/database/runInstaller -silent -waitforcompletion -ignoreSysPrereqs -ignorePrereq -responseFile ${downloadDir}/db_install_${version}.rsp'",
        creates     => $oracleHome,
        timeout     => 0,
        returns     => [6,0],
        path        => $execPath,
        user        => $user,
        group       => $group_install,
        logoutput   => true,
        require     => [Oradb::Utils::Orainst["database orainst ${version}"],
                        File["${downloadDir}/db_install_${version}.rsp"]],
      }

      file { $oracleHome:
        ensure  => directory,
        recurse => false,
        replace => false,
        mode    => '0775',
        owner   => $user,
        group   => $group_install,
        require => Exec["install oracle database ${title}"],
      }
    }

    if ! defined(File["${userBaseDir}/${user}/.bash_profile"]) {
      file { "${userBaseDir}/${user}/.bash_profile":
        ensure  => present,
        content => template("oradb/bash_profile.erb"),
        mode    => '0775',
        owner   => $user,
        group   => $group,
        require => Oradb::Utils::Structure["oracle structure ${version}"],
      }
    }

    exec { "run root.sh script ${title}":
      command   => "${oracleHome}/root.sh",
      user      => 'root',
      group     => 'root',
      path      => $execPath,
      logoutput => true,
      require   => Exec["install oracle database ${title}"],
    }
  }
}
