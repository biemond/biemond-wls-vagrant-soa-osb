# test
#
# one machine setup with weblogic 10.3.6 with BSU
# needs jdk7, orawls, orautils, fiddyspence-sysctl, erwbgy-limits puppet modules
#

node 'soaapp.example.com' {
  
   include os, java, ssh, orautils 
   include wls1036
   include wls1036_domain
   include maintenance
   
   Class['os']  -> 
     Class['ssh']  -> 
       Class['java']  -> 
         Class['wls1036'] -> 
           Class['wls1036_domain']
}  

# operating settings for Middleware
class os {

  notice "class os ${operatingsystem}"

  $default_params = {}
  $host_instances = hiera('hosts', [])
  create_resources('host',$host_instances, $default_params)

  exec { "create swap file":
    command => "/bin/dd if=/dev/zero of=/var/swap.1 bs=1M count=8192",
    creates => "/var/swap.1",
  }

  exec { "attach swap file":
    command => "/sbin/mkswap /var/swap.1 && /sbin/swapon /var/swap.1",
    require => Exec["create swap file"],
    unless => "/sbin/swapon -s | grep /var/swap.1",
  }

  #add swap file entry to fstab
  exec {"add swapfile entry to fstab":
    command => "/bin/echo >>/etc/fstab /var/swap.1 swap swap defaults 0 0",
    require => Exec["attach swap file"],
    user => root,
    unless => "/bin/grep '^/var/swap.1' /etc/fstab 2>/dev/null",
  }

  service { iptables:
        enable    => false,
        ensure    => false,
        hasstatus => true,
  }

  group { 'dba' :
    ensure => present,
  }

  # http://raftaman.net/?p=1311 for generating password
  # password = oracle
  user { 'oracle' :
    ensure     => present,
    groups     => 'dba',
    shell      => '/bin/bash',
    password   => '$1$DSJ51vh6$4XzzwyIOk6Bi/54kglGk3.',
    home       => "/home/oracle",
    comment    => 'oracle user created by Puppet',
    managehome => true,
    require    => Group['dba'],
  }

  $install = [ 'binutils.x86_64','unzip.x86_64']


  package { $install:
    ensure  => present,
  }

  class { 'limits':
    config => {
               '*'       => {  'nofile'  => { soft => '2048'   , hard => '8192',   },},
               'oracle'  => {  'nofile'  => { soft => '65536'  , hard => '65536',  },
                               'nproc'   => { soft => '2048'   , hard => '16384',   },
                               'memlock' => { soft => '1048576', hard => '1048576',},
                               'stack'   => { soft => '10240'  ,},},
               },
    use_hiera => false,
  }

  sysctl { 'kernel.msgmnb':                 ensure => 'present', permanent => 'yes', value => '65536',}
  sysctl { 'kernel.msgmax':                 ensure => 'present', permanent => 'yes', value => '65536',}
  sysctl { 'kernel.shmmax':                 ensure => 'present', permanent => 'yes', value => '2588483584',}
  sysctl { 'kernel.shmall':                 ensure => 'present', permanent => 'yes', value => '2097152',}
  sysctl { 'fs.file-max':                   ensure => 'present', permanent => 'yes', value => '6815744',}
  sysctl { 'net.ipv4.tcp_keepalive_time':   ensure => 'present', permanent => 'yes', value => '1800',}
  sysctl { 'net.ipv4.tcp_keepalive_intvl':  ensure => 'present', permanent => 'yes', value => '30',}
  sysctl { 'net.ipv4.tcp_keepalive_probes': ensure => 'present', permanent => 'yes', value => '5',}
  sysctl { 'net.ipv4.tcp_fin_timeout':      ensure => 'present', permanent => 'yes', value => '30',}
  sysctl { 'kernel.shmmni':                 ensure => 'present', permanent => 'yes', value => '4096', }
  sysctl { 'fs.aio-max-nr':                 ensure => 'present', permanent => 'yes', value => '1048576',}
  sysctl { 'kernel.sem':                    ensure => 'present', permanent => 'yes', value => '250 32000 100 128',}
  sysctl { 'net.ipv4.ip_local_port_range':  ensure => 'present', permanent => 'yes', value => '9000 65500',}
  sysctl { 'net.core.rmem_default':         ensure => 'present', permanent => 'yes', value => '262144',}
  sysctl { 'net.core.rmem_max':             ensure => 'present', permanent => 'yes', value => '4194304', }
  sysctl { 'net.core.wmem_default':         ensure => 'present', permanent => 'yes', value => '262144',}
  sysctl { 'net.core.wmem_max':             ensure => 'present', permanent => 'yes', value => '1048576',}

}

class ssh {
  require os

  notice 'class ssh'

  file { "/home/oracle/.ssh/":
    owner  => "oracle",
    group  => "dba",
    mode   => "700",
    ensure => "directory",
    alias  => "oracle-ssh-dir",
  }
  
  file { "/home/oracle/.ssh/id_rsa.pub":
    ensure  => present,
    owner   => "oracle",
    group   => "dba",
    mode    => "644",
    source  => "/vagrant/ssh/id_rsa.pub",
    require => File["oracle-ssh-dir"],
  }
  
  file { "/home/oracle/.ssh/id_rsa":
    ensure  => present,
    owner   => "oracle",
    group   => "dba",
    mode    => "600",
    source  => "/vagrant/ssh/id_rsa",
    require => File["oracle-ssh-dir"],
  }
  
  file { "/home/oracle/.ssh/authorized_keys":
    ensure  => present,
    owner   => "oracle",
    group   => "dba",
    mode    => "644",
    source  => "/vagrant/ssh/id_rsa.pub",
    require => File["oracle-ssh-dir"],
  }        
}

class java {
  require os

  notice 'class java'

  $remove = [ "java-1.7.0-openjdk.x86_64", "java-1.6.0-openjdk.x86_64" ]

  package { $remove:
    ensure  => absent,
  }

  include jdk7

  jdk7::install7{ 'jdk1.7.0_45':
      version              => "7u45" , 
      fullVersion          => "jdk1.7.0_45",
      alternativesPriority => 18000, 
      x64                  => true,
      downloadDir          => hiera('wls_download_dir'),
      urandomJavaFix       => true,
      sourcePath           => hiera('wls_source'),
  }

}

class wls1036{

   class { 'wls::urandomfix' :}

   $jdkWls11gJDK  = hiera('wls_jdk_version')
   $wls11gVersion = hiera('wls_version')
                       
   $puppetDownloadMntPoint = hiera('wls_source')                       
 
   $osOracleHome = hiera('wls_oracle_base_home_dir')
   $osMdwHome    = hiera('wls_middleware_home_dir')
   $osWlHome     = hiera('wls_weblogic_home_dir')
   $user         = hiera('wls_os_user')
   $group        = hiera('wls_os_group')
   $downloadDir  = hiera('wls_download_dir')
   $logDir       = hiera('wls_log_dir')     


  # install
  wls::installwls{'11gPS5':
    version                => $wls11gVersion,
    fullJDKName            => $jdkWls11gJDK,
    oracleHome             => $osOracleHome,
    mdwHome                => $osMdwHome,
    user                   => $user,
    group                  => $group,    
    downloadDir            => $downloadDir,
    remoteFile             => hiera('wls_remote_file'),
    puppetDownloadMntPoint => $puppetDownloadMntPoint,
    createUser             => false, 
  }
  
  # weblogic patch
  wls::bsupatch{'p17071663':
    mdwHome                => $osMdwHome,
    wlHome                 => $osWlHome,
    fullJDKName            => $jdkWls11gJDK,
    user                   => $user,
    group                  => $group,
    downloadDir            => $downloadDir, 
    puppetDownloadMntPoint => $puppetDownloadMntPoint, 
    patchId                => 'BYJ1',    
    patchFile              => 'p17071663_1036_Generic.zip',  
    remoteFile             => hiera('wls_remote_file'),
    require                => Wls::Installwls['11gPS5'],
  }

  wls::installsoa{'soaPS6':
    mdwHome                => $osMdwHome,
    wlHome                 => $osWlHome,
    oracleHome             => $osOracleHome,
    fullJDKName            => $jdkWls11gJDK,  
    user                   => $user,
    group                  => $group,    
    downloadDir            => $downloadDir,
    puppetDownloadMntPoint => $puppetDownloadMntPoint, 
    soaFile1               => 'ofm_soa_generic_11.1.1.7.0_disk1_1of2.zip',
    soaFile2               => 'ofm_soa_generic_11.1.1.7.0_disk1_2of2.zip',
    remoteFile             => hiera('wls_remote_file'),
    require                => Wls::Bsupatch['p17071663'],
  }

  wls::opatch{'17014142_soa_patch':
    fullJDKName            => $jdkWls11gJDK,
    user                   => $user,
    group                  => $group,
    downloadDir            => $downloadDir, 
    remoteFile             => hiera('wls_remote_file'),
    puppetDownloadMntPoint => $puppetDownloadMntPoint, 
    oracleProductHome      => "${osMdwHome}/Oracle_SOA1" ,
    patchId                => '17014142',
    patchFile              => 'p17014142_111170_Generic.zip',
    require                => Wls::Installsoa['soaPS6'],
  }

  wls::installosb{'osbPS6':
    mdwHome                => $osMdwHome,
    wlHome                 => $osWlHome,
    oracleHome             => $osOracleHome,
    fullJDKName            => $jdkWls11gJDK,  
    user                   => $user,
    group                  => $group,    
    downloadDir            => $downloadDir,
    puppetDownloadMntPoint => $puppetDownloadMntPoint, 
    osbFile                => 'ofm_osb_generic_11.1.1.7.0_disk1_1of1.zip',
    remoteFile             => hiera('wls_remote_file'),
    require                => Wls::Opatch['17014142_soa_patch'],
  }

  #nodemanager configuration and starting
  wls::nodemanager{'nodemanager11g':
    wlHome        => $osWlHome,
    fullJDKName   => $jdkWls11gJDK,  
    user          => $user,
    group         => $group,
    serviceName   => $serviceName,  
    downloadDir   => $downloadDir, 
    listenPort    => hiera('domain_nodemanager_port'),
    listenAddress => hiera('domain_adminserver_address'),
    logDir        => $logDir,
    require       => Wls::Installosb['osbPS6'],
  }

}

class wls1036_domain{


  $wlsDomainName   = hiera('domain_name')
  $wlsDomainsPath  = hiera('wls_domains_path_dir')
  $osTemplate      = hiera('domain_template')

  $adminListenPort = hiera('domain_adminserver_port')
  $nodemanagerPort = hiera('domain_nodemanager_port')
  $address         = hiera('domain_adminserver_address')

  $userConfigDir   = hiera('wls_user_config_dir')
  $jdkWls11gJDK    = hiera('wls_jdk_version')
                       
  $osOracleHome = hiera('wls_oracle_base_home_dir')
  $osMdwHome    = hiera('wls_middleware_home_dir')
  $osWlHome     = hiera('wls_weblogic_home_dir')
  $user         = hiera('wls_os_user')
  $group        = hiera('wls_os_group')
  $downloadDir  = hiera('wls_download_dir')
  $logDir       = hiera('wls_log_dir')     

  $reposUrl        = "jdbc:oracle:thin:@soadb.example.com:1521/test.oracle.com"
  $reposPrefix     = "DEV"
  $reposPassword   = "Welcome01"

  orautils::nodemanagerautostart{"autostart ${wlsDomainName}":
    version     => "1111",
    wlHome      => $osWlHome, 
    user        => $user,
    logDir      => $logDir,
  }

  # install SOA OIM OAM domain
  wls::wlsdomain{'soaDomain':
    version         => "1111",
    wlHome          => $osWlHome,
    mdwHome         => $osMdwHome,
    fullJDKName     => $jdkWls11gJDK, 
    wlsTemplate     => $osTemplate,
    domain          => $wlsDomainName,
    developmentMode => false,
    adminServerName => hiera('domain_adminserver'),
    adminListenAdr  => $address,
    adminListenPort => $adminListenPort,
    nodemanagerPort => $nodemanagerPort,
    wlsUser         => hiera('wls_weblogic_user'),
    password        => hiera('domain_wls_password'),
    user            => $user,
    group           => $group,    
    logDir          => $logDir,
    downloadDir     => $downloadDir, 
    reposDbUrl      => $reposUrl,
    reposPrefix     => $reposPrefix,
    reposPassword   => $reposPassword,
  }

  Wls::Wlscontrol{
    wlsDomain     => $wlsDomainName,
    wlsDomainPath => "${wlsDomainsPath}/${wlsDomainName}",
    wlHome        => $osWlHome,
    fullJDKName   => $jdkWls11gJDK,  
    wlsUser       => hiera('wls_weblogic_user'),
    password      => hiera('domain_wls_password'),
    address       => $address,
    user          => $user,
    group         => $group,
    downloadDir   => $downloadDir,
    logOutput     => true, 
  }

  # start AdminServers for configuration of WLS Domain
  wls::wlscontrol{'startAdminServer':
    wlsServerType => 'admin',
    wlsServer     => "AdminServer",
    action        => 'start',
    port          => $nodemanagerPort,
    require       => Wls::Wlsdomain['soaDomain'],
  }

  # create keystores for automatic WLST login
  wls::storeuserconfig{'soaDomain_keys':
    wlHome        => $osWlHome,
    fullJDKName   => $jdkWls11gJDK,
    domain        => $wlsDomainName, 
    address       => $address,
    wlsUser       => hiera('wls_weblogic_user'),
    password      => hiera('domain_wls_password'),
    port          => $adminListenPort,
    user          => $user,
    group         => $group,
    userConfigDir => $userConfigDir, 
    downloadDir   => $downloadDir, 
    require       => Wls::Wlscontrol['startAdminServer'],
  }

  # # start Soa server for configuration
  # wls::wlscontrol{'startSoaServer1':
  #     wlsServerType => 'managed',
  #     wlsServer     => "soa_server1",
  #     action        => 'start',
  #     port          => $adminListenPort,
  #     require       => Wls::Storeuserconfig['soaDomain_keys'],
  # } 

  # # start Oim server for configuration
  # wls::wlscontrol{'startOsbServer1':
  #     wlsServerType => 'managed',
  #     wlsServer     => "osb_server1",
  #     action        => 'start',
  #     port          => $adminListenPort,
  #     require       => Wls::Wlscontrol['startSoaServer1'],
  # } 

}

class maintenance {

  $osOracleHome = hiera('wls_oracle_base_home_dir')
  $osMdwHome    = hiera('wls_middleware_home_dir')
  $osWlHome     = hiera('wls_weblogic_home_dir')
  $user         = hiera('wls_os_user')
  $group        = hiera('wls_os_group')
  $downloadDir  = hiera('wls_download_dir')
  $logDir       = hiera('wls_log_dir')     

  $mtimeParam = "1"


  cron { 'cleanwlstmp' :
        command => "find /tmp -name '*.tmp' -mtime ${mtimeParam} -exec rm {} \\; >> /tmp/tmp_purge.log 2>&1",
        user    => oracle,
        hour    => 06,
        minute  => 25,
  }
     
  cron { 'mdwlogs' :
        command => "find ${osMdwHome}/logs -name 'wlst_*.*' -mtime ${mtimeParam} -exec rm {} \\; >> /tmp/wlst_purge.log 2>&1",
        user    => oracle,
        hour    => 06,
        minute  => 30,
  }
     
  cron { 'oracle_common_lsinv' :
        command => "find ${osMdwHome}/oracle_common/cfgtoollogs/opatch/lsinv -name 'lsinventory*.txt' -mtime ${mtimeParam} -exec rm {} \\; >> /tmp/opatch_lsinv_common_purge.log 2>&1",
        user    => oracle,
        hour    => 06,
        minute  => 31,
  }
     

  cron { 'oracle_soa1_lsinv' :
        command => "find ${osMdwHome}/Oracle_SOA1/cfgtoollogs/opatch/lsinv -name 'lsinventory*.txt' -mtime ${mtimeParam} -exec rm {} \\; >> /tmp/opatch_lsinv_soa1_purge.log 2>&1",
        user    => oracle,
        hour    => 06,
        minute  => 33,
  }
     
  cron { 'oracle_common_opatch' :
        command => "find ${osMdwHome}/oracle_common/cfgtoollogs/opatch -name 'opatch*.log' -mtime ${mtimeParam} -exec rm {} \\; >> /tmp/opatch_common_purge.log 2>&1",
        user    => oracle,
        hour    => 06,
        minute  => 34,
  }
     
     
  cron { 'oracle_soa1_opatch' :
        command => "find ${osMdwHome}/Oracle_SOA1/cfgtoollogs/opatch -name 'opatch*.log' -mtime ${mtimeParam} -exec rm {} \\; >> /tmp/opatch_soa_purge.log 2>&1",
        user    => oracle,
        hour    => 06,
        minute  => 35,
  }
    

}


