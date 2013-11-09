name 'cloudstack-standalone'
run_list(
  'recipe[cloudstack-kvm-hypervisor]',
  'recipe[cloudstack-management-server]'
)
default_attributes(
  "cloudstack_management_server" => {
    "is_also_kvm_hypervisor" => true
  }
)
