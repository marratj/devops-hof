module "vm" {
    source = "../modules/simple_vm"

    machine_type = "n1-standard-1"
    vm_name = "testvm"
    vm_count = 3

    # service_account = google_service_account.service_account.email
}

# resource "google_service_account" "service_account" {
#   account_id   = "vm-account"
#   display_name = "VM Account"
#   project = var.project
# }