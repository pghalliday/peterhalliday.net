name 'cloudstack-standalone'
run_list(
  'recipe[cloudstack-kvm-hypervisor]',
  'recipe[cloudstack-management-server]'
)
