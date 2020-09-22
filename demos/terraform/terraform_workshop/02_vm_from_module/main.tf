module "vm" {
    source = "../modules/simple_vm"

    machine_type = "n1-standard-1"
    vm_name = "testvm"
    vm_count = 3
}
