Vagrant.configure("2") do |config|
  config.vm.box = "precise-server-cloudimg-amd64"
  config.vm.box_url = "http://cloud-images.ubuntu.com/vagrant/precise/current/precise-server-cloudimg-amd64-vagrant-disk1.box"

  config.vm.network "private_network", ip: "192.168.50.4"
  config.vm.hostname = "cs-test.peterhalliday.net"

  config.vm.provider :virtualbox do |vb|
    vb.customize [
      "modifyvm", :id,
      "--memory", "4096",
      "--cpus", "2",
    ]
  end
end
