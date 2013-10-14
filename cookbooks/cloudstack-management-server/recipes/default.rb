# disable apparmor
include_recipe 'apparmor'

apt_repository 'cloudstack' do
  uri          'http://cloudstack.apt-get.eu/ubuntu'
  distribution 'precise'
  components   ['4.2']
  key          'http://cloudstack.apt-get.eu/release.asc'
end

package 'openntpd'
package 'cloudstack-management'

include_recipe 'mysql::server'

template '/etc/mysql/conf.d/cloudstack.cnf' do
  source 'cloudstack.cnf.erb'
  mode 0644
  owner 'root'
  group 'root'
  notifies :restart, 'service[mysql]', :immediately
end

bash 'create cloud database user' do
  code <<-EOH
    cloudstack-setup-databases cloud:#{node[:cloudstack_manager][:cloud_db_password]}@localhost --deploy-as=root:#{node[:mysql][:server_root_password]}
    EOH
end

if node[:cloudstack_manager][:is_also_kvm_hypervisor]
  node.default[:authorization][:sudo][:sudoers_defaults] = ['cloud !requiretty']
  include_recipe 'sudo'
end

bash 'set up and start management server' do
  code <<-EOH
    cloudstack-setup-management
    EOH
end

node.default["nfs"]["port"]['statd'] = 662
node.default["nfs"]["port"]['statd_out'] = 2020
node.default["nfs"]["port"]['mountd'] = 892
node.default["nfs"]["port"]['lockd'] = 32803
include_recipe 'nfs::server'

directory "/export/primary" do
  owner "root"
  group "root"
  mode 00644
  recursive true
end

directory "/export/secondary" do
  owner "root"
  group "root"
  mode 00644
  recursive true
end

nfs_export "/exports" do
  network '*'
  writeable true 
  sync false
  options ['no_root_squash']
end

include_recipe 'iptables'
iptables_rule 'nfs'

bash 'import KVM template' do
  code <<-EOH
    /usr/share/cloudstack-common/scripts/storage/secondary/cloud-install-sys-tmplt -m /export/secondary -u http://download.cloud.com/templates/acton/acton-systemvm-02062012.qcow2.bz2 -h kvm -F
    EOH
end
