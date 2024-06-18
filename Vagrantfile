# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  # Load Balancer 1
  config.vm.define "loadbalancer1" do |lb1|
    lb1.vm.box = "bento/ubuntu-22.04"
    lb1.vm.hostname = "loadbalancer1"
    lb1.vm.network :private_network, ip: "192.168.44.11"
    lb1.vm.provider "virtualbox" do |v|
      v.name = "Project_O-loadbalancer1"
      v.memory = 1024
      v.cpus = 1
      v.linked_clone = true
    end
    lb1.vm.provision "shell", path: "./provision/nginx_loadbalancer.sh"
  end

  # Load Balancer 2
  config.vm.define "loadbalancer2" do |lb2|
    lb2.vm.box = "bento/ubuntu-22.04"
    lb2.vm.hostname = "loadbalancer2"
    lb2.vm.network :private_network, ip: "192.168.44.12"
    lb2.vm.provider "virtualbox" do |v|
      v.name = "Project_O-loadbalancer2"
      v.memory = 1024
      v.cpus = 1
      v.linked_clone = true
    end
    lb2.vm.provision "shell", path: "./provision/nginx_loadbalancer.sh"
  end
