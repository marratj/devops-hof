terraform {
  backend "gcs" {
    bucket  = "devops-hof-eu-tfstate"
    prefix  = "terraform/vm_from_module"
  }
}