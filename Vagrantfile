# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  config.vm.define "webapp" do |node|
      node.vm.box = "bento/ubuntu-22.04"
      node.vm.hostname = "webapp"
      node.vm.network :private_network, ip: "192.168.44.10"
      node.vm.provider "virtualbox" do |v|
        v.name = "Project_O-webapp"
        v.memory = 2048
        v.cpus = 2
        v.linked_clone = true
      end
      node.vm.provision "shell", path: "./provision/web.sh"

      # the box generic/alpine might not have shared folders by default
      #node.vm.synced_folder "app/", "/var/www/html"
    end

end
