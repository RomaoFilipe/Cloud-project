# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  # Configuração do servidor Consul
  config.vm.define "consul" do |consul|
    consul.vm.box = "bento/ubuntu-22.04"
    consul.vm.hostname = "consul"
    consul.vm.network :private_network, ip: "192.168.44.15"
    consul.vm.provider "virtualbox" do |v|
      v.name = "Project_A-consul"
      v.memory = 1024
      v.cpus = 2
      v.linked_clone = true
    end
    consul.vm.provision "shell", path: "./provision/consul.sh"
  end

  # Configuração do primeiro load balancer
  config.vm.define "loadbalancer1" do |lb|
    lb.vm.box = "bento/ubuntu-22.04"
    lb.vm.hostname = "loadbalancer1"
    lb.vm.network :private_network, ip: "192.168.44.10"
    lb.vm.provider "virtualbox" do |v|
      v.name = "Project_A-loadbalancer1"
      v.memory = 1024
      v.cpus = 1
      v.linked_clone = true
    end
    lb.vm.provision "shell", path: "./provision/loadbalancer.sh"
  end

  # Configuração do segundo load balancer
  config.vm.define "loadbalancer2" do |lb|
    lb.vm.box = "bento/ubuntu-22.04"
    lb.vm.hostname = "loadbalancer2"
    lb.vm.network :private_network, ip: "192.168.44.21"
    lb.vm.provider "virtualbox" do |v|
      v.name = "Project_A-loadbalancer2"
      v.memory = 1024
      v.cpus = 1
      v.linked_clone = true
    end
    lb.vm.provision "shell", path: "./provision/loadbalancer2.sh"
  end

  # Configuração dos servidores web
  (1..3).each do |i|
    config.vm.define "webapp#{i}" do |web|
      web.vm.box = "bento/ubuntu-22.04"
      web.vm.hostname = "webapp#{i}"
      web.vm.network :private_network, ip: "192.168.44.1#{i}"
      web.vm.provider "virtualbox" do |v|
        v.name = "Project_A-webapp#{i}"
        v.memory = 1024
        v.cpus = 2
        v.linked_clone = true
      end
      web.vm.provision "shell", path: "./provision/web.sh"
    end
  end

  # Configuração do servidor de banco de dados
  config.vm.define "database" do |db|
    db.vm.box = "bento/ubuntu-22.04"
    db.vm.hostname = "database"
    db.vm.network :private_network, ip: "192.168.44.20"
    db.vm.provider "virtualbox" do |v|
      v.name = "Project_A-database"
      v.memory = 1024
      v.cpus = 2
      v.linked_clone = true
    end
    db.vm.provision "shell", path: "./provision/database.sh"
  end

  # Configuração do servidor WebSockets
  config.vm.define "websockets" do |ws|
    ws.vm.box = "bento/ubuntu-22.04"
    ws.vm.hostname = "websockets"
    ws.vm.network :private_network, ip: "192.168.44.30"
    ws.vm.provider "virtualbox" do |v|
      v.name = "Project_A-websockets"
      v.memory = 1024
      v.cpus = 1
      v.linked_clone = true
    end
    ws.vm.provision "shell", path: "./provision/websockets.sh"
  end

end
