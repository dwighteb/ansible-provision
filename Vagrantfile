# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.define "xenial" do |xenial|
    xenial.vm.box = "ubuntu/xenial64"
#    xenial.vm.network "forwarded_port", guest: 80, host: 8080
  end
  config.vm.define "centos6" do |centos6|
    centos6.vm.box = "bento/centos-6.7"
  end
#  config.vm.define "freebsd" do |freebsd|
#    freebsd.vm.box = "freebsd/FreeBSD-10.2-STABLE"
#    freebsd.ssh.shell = 'sh'
#    freebsd.vm.synced_folder '.', '/vagrant', disabled: true
#  end

  config.vm.provision "ansible" do |ansible|
    ansible.verbose = "v"
    ansible.groups = {
        "openvpn" => ["xenial"]
    }
    ansible.playbook = "playbook/vagrant.yml"
    ansible.vault_password_file = "~/.vault_pass.txt"
  end
end
