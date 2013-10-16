default[:mysql][:server_root_password] = 'root'
default[:mysql][:server_repl_password] = 'repl'
default[:mysql][:server_debian_password] = 'debian'
default[:mysql][:bind_address] = '0.0.0.0'

default[:cloudstack_management_server][:is_also_kvm_hypervisor] = false
default[:cloudstack_management_server][:cloud_db_password] = 'cloud'
default[:cloudstack_management_server][:domain] = 'peterhalliday.net'
