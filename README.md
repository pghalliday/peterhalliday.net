peterhalliday.net
=================

Cookbooks for home network

Prerequisites
-------------

- Sign up for [Enterprise Chef](https://www.opscode.com/)
- Create an organization
- Download the organization validator key file and place in `.chef`
- Download the organization `knife.rb` file and place in `.chef`
- Download your user key file and place in `.chef`
- [VirtualBox](https://www.virtualbox.org/wiki/Downloads)
- [Vagrant](http://downloads.vagrantup.com/)
- The Vagrant bindler plugin

```
vagrant plugin install bindler
vagrant bindler setup
```

Getting started
---------------

Create a knife environment using Vagrant from the `knife` directory.

```
cd knife
vagrant plugin bundle
vagrant up
vagrant ssh
```

Download the community cookbooks and upload all the cookbooks to the chef server.

```
cd /chef-repo
berks
berks upload
```

Upload the roles

```
knife role from file roles/*
```

Bootstrap a standalone Cloudstack management server and kvm hypervisor
----------------------------------------------------------------------

To test, boot the vagrant box in the root of the project to get a vanilla ubuntu 12.04 server on IP 192.168.50.4. When prompted, the root password is `vagrant`

```
knife bootstrap 192.168.50.4 -r 'role[cloudstack-standalone]'
```
