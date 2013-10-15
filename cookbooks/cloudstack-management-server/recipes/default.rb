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

cookbook_file '/etc/mysql/conf.d/cloudstack.cnf' do
  source 'cloudstack.cnf'
  mode 0644
  owner 'root'
  group 'root'
  notifies :restart, 'service[mysql]', :immediately
end

bash 'create cloud database user' do
  code <<-EOH
    cloudstack-setup-databases cloud:#{node[:cloudstack_management_server][:cloud_db_password]}@localhost --deploy-as=root:#{node[:mysql][:server_root_password]}
    EOH
end

if node[:cloudstack_management_server][:is_also_kvm_hypervisor]
  node.default[:authorization][:sudo][:sudoers_defaults] = ['cloud !requiretty']
  include_recipe 'sudo'
end

bash 'set up and start management server' do
  code <<-EOH
    cloudstack-setup-management
    EOH
end

package "nfs-kernel-server"
package "rpcbind"

cookbook_file '/etc/network/if-pre-up.d/iptablesload' do
  source 'iptablesload'
  mode 0755
  owner 'root'
  group 'root'
end

cookbook_file '/etc/network/if-post-down.d/iptablessave' do
  source 'iptablessave'
  mode 0755
  owner 'root'
  group 'root'
end

bash 'configure iptables for nfs' do
  code <<-EOH
    iptables -A INPUT -m state --state NEW -p udp --dport 111 -j ACCEPT
    iptables -A INPUT -m state --state NEW -p tcp --dport 111 -j ACCEPT
    iptables -A INPUT -m state --state NEW -p tcp --dport 2049 -j ACCEPT
    iptables -A INPUT -m state --state NEW -p tcp --dport 32803 -j ACCEPT
    iptables -A INPUT -m state --state NEW -p udp --dport 32769 -j ACCEPT
    iptables -A INPUT -m state --state NEW -p tcp --dport 892 -j ACCEPT
    iptables -A INPUT -m state --state NEW -p udp --dport 892 -j ACCEPT
    iptables -A INPUT -m state --state NEW -p tcp --dport 875 -j ACCEPT
    iptables -A INPUT -m state --state NEW -p udp --dport 875 -j ACCEPT
    iptables -A INPUT -m state --state NEW -p tcp --dport 662 -j ACCEPT
    iptables -A INPUT -m state --state NEW -p udp --dport 662 -j ACCEPT
    /etc/network/if-post-down.d/iptablessave
    EOH
  notifies :restart, 'service[nfs-kernel-server]', :delayed
  notifies :restart, 'service[networking]', :delayed
end

cookbook_file '/etc/default/nfs-kernel-server' do
  source 'nfs-kernel-server'
  mode 0644
  owner 'root'
  group 'root'
  notifies :restart, 'service[nfs-kernel-server]', :delayed
  notifies :restart, 'service[networking]', :delayed
end

template '/etc/imapd.conf' do
  source 'imapd.conf.erb'
  mode 0644
  owner 'root'
  group 'root'
  notifies :restart, 'service[nfs-kernel-server]', :delayed
  notifies :restart, 'service[networking]', :delayed
end

directory "/export/primary" do
  owner "root"
  group "root"
  mode 0755
  recursive true
end

directory "/export/secondary" do
  owner "root"
  group "root"
  mode 0755
  recursive true
end

cookbook_file '/etc/exports' do
  source 'exports'
  mode 0644
  owner 'root'
  group 'root'
  notifies :restart, 'service[nfs-kernel-server]', :delayed
  notifies :restart, 'service[networking]', :delayed
end

service 'nfs-kernel-server' do
  supports :restart => true
  action :start
end

service 'networking' do
  supports :restart => true
  action :start
end

bash 'import KVM template' do
  code <<-EOH
    /usr/share/cloudstack-common/scripts/storage/secondary/cloud-install-sys-tmplt -m /export/secondary -u http://download.cloud.com/templates/acton/acton-systemvm-02062012.qcow2.bz2 -h kvm -F
    EOH
end
