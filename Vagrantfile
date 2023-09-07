# -*- mode: ruby -*-
# vi: set ft=ruby :

BOX_NAME = ENV["BOX_NAME"] || "bento/ubuntu-22.04"
BOX_MEMORY = ENV["BOX_MEMORY"] || "2048"
DOKKU_VERSION = "master"

Vagrant.configure(2) do |config|
  config.vm.box = BOX_NAME
  config.ssh.forward_agent = true

  config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm", :id, "--memory", BOX_MEMORY]
  end

  config.vm.provider :vmware_fusion do |v, override|
    v.vmx["memsize"] = BOX_MEMORY
  end

  config.vm.define "default", primary: true do |vm|
    vm.vm.synced_folder File.dirname(__FILE__), "/vagrant"

    vm.vm.provision :shell, :inline => "apt -q update && apt -y -qq install git software-properties-common"
    vm.vm.provision :shell, :inline => "cd /vagrant && DOKKU_VERSION=#{DOKKU_VERSION} make setup"
    vm.vm.provision :shell, :inline => "cd /vagrant && DOKKU_TRACE=1 DOKKU_VERSION=#{DOKKU_VERSION} make test"
  end
end
