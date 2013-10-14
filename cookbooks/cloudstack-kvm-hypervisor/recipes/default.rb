# disable apparmor
include_recipe 'apparmor'

apt_repository 'cloudstack' do
  uri          'http://cloudstack.apt-get.eu/ubuntu'
  distribution 'precise'
  components   ['4.2']
  key          'http://cloudstack.apt-get.eu/release.asc'
end

package 'qemu-kvm'
package 'libvirt-bin'
package 'openntpd'
package 'cloudstack-agent'

template '/etc/libvirt/libvirtd.conf' do
  source 'libvirtd.conf.erb'
  mode 0644
  owner 'root'
  group 'root'
  notifies :restart, 'service[libvirt-bin]', :delayed
end

template '/etc/default/libvirt-bin' do
  source 'libvirt-bin.erb'
  mode 0644
  owner 'root'
  group 'root'
  notifies :restart, 'service[libvirt-bin]', :delayed
end

template '/etc/libvirt/qemu.conf' do
  source 'qemu.conf.erb'
  mode 0644
  owner 'root'
  group 'root'
  notifies :restart, 'service[libvirt-bin]', :delayed
end

service "libvirt-bin" do
  provider Chef::Provider::Service::Upstart
  supports :restart => true
  action :start
end
