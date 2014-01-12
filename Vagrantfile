# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.define "soaapp" , primary: true do |soaapp|
    soaapp.vm.box = "centos-6.5-x86_64"
    #soaapp.vm.box_url ="/Users/edwin/Downloads/centos-6.5-x86_64.box"
    soaapp.vm.box_url = "https://dl.dropboxusercontent.com/s/np39xdpw05wfmv4/centos-6.5-x86_64.box"

    soaapp.vm.hostname = "soaapp.example.com"

    soaapp.vm.synced_folder "."                    , "/vagrant", :mount_options => ["dmode=777","fmode=777"]
    soaapp.vm.synced_folder "/Users/edwin/software", "/software"
    #soaapp.vm.synced_folder "."                    , "/vagrant" , type: "nfs"
    #soaapp.vm.synced_folder "/Users/edwin/software", "/software", type: "nfs"

  
    soaapp.vm.network :private_network, ip: "10.10.10.10"
  
    soaapp.vm.provider :virtualbox do |vb|
      vb.customize ["modifyvm", :id, "--memory", "3500"]
      vb.customize ["modifyvm", :id, "--name"  , "soaapp"]
    end
  
    soaapp.vm.provision :shell, :inline => "ln -sf /vagrant/puppet/hiera.yaml /etc/puppet/hiera.yaml"
    
    soaapp.vm.provision :puppet do |puppet|
      puppet.manifests_path    = "puppet/manifests"
      puppet.module_path       = "puppet/modules"
      puppet.manifest_file     = "soaapp.pp"
      puppet.options           = "--verbose --hiera_config /vagrant/puppet/hiera.yaml"
  
      puppet.facter = {
        "environment"                     => "development",
        "vm_type"                         => "vagrant",
      }
      
    end
  
  end

  config.vm.define "soadb" , primary: true do |soadb|
    soadb.vm.box = "centos-6.5-x86_64"
    soadb.vm.box_url = "https://dl.dropboxusercontent.com/s/np39xdpw05wfmv4/centos-6.5-x86_64.box"

    soadb.vm.hostname = "soadb.example.com"
    soadb.vm.network :private_network, ip: "10.10.10.5"

    soadb.vm.synced_folder ".", "/vagrant", :mount_options => ["dmode=777","fmode=777"]
    soadb.vm.synced_folder "/Users/edwin/software", "/software"
    #soadb.vm.synced_folder ".", "/vagrant", type: "nfs"
    #soadb.vm.synced_folder "/Users/edwin/software", "/software", type: "nfs"
  
    soadb.vm.provider :virtualbox do |vb|
      vb.customize ["modifyvm"     , :id, "--memory", "2000"]
      vb.customize ["modifyvm"     , :id, "--name"  , "soadb"]
    end

  
    soadb.vm.provision :shell, :inline => "ln -sf /vagrant/puppet/hiera.yaml /etc/puppet/hiera.yaml"
    
    soadb.vm.provision :puppet do |puppet|
      puppet.manifests_path    = "puppet/manifests"
      puppet.module_path       = "puppet/modules"
      puppet.manifest_file     = "soadb.pp"
      puppet.options           = "--verbose --hiera_config /vagrant/puppet/hiera.yaml"
  
      puppet.facter = {
        "environment" => "development",
        "vm_type"     => "vagrant",
      }
      
    end
  
  end  



end
