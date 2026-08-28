resource "vagrant_vm" "this" {
  name            = "vagrantbox" # метка для Terraform; имя в VirtualBox задаёт vb.name в Vagrantfile
  vagrantfile_dir = var.vagrantfile_dir
  get_ports       = true
}

locals {
  raw = vagrant_vm.this.ssh_config[
    index(vagrant_vm.this.machine_names, var.machine_name)
  ]
}
