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

```
knife bootstrap cs.peterhalliday.net -r 'role[cloudstack-standalone]' -x pghalliday -P varsity1
```

to rerun the chef client

```
knife ssh 'name:cs.peterhalliday.net' 'sudo chef-client' -x pghalliday -P varsity1
```
