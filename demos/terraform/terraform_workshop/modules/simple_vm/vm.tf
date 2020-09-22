resource "google_compute_instance" "default" {
  count = var.vm_count
  name         = "${var.vm_name}-${count.index}"
  machine_type = var.machine_type
  zone         = var.zone
  project      = var.project

  tags = var.tags

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

  // Local SSD disk
  scratch_disk {
    interface = "SCSI"
  }

  network_interface {
    network = "default"

    access_config {
      // Ephemeral IP
    }
  }

  metadata = {
    foo = "bar"
  }

  metadata_startup_script = "echo hi > /test.txt"

  service_account {
    email = "blafasel@${var.region}.iam.gserviceaccount.com"
    scopes = ["userinfo-email", "compute-ro", "storage-ro"]
  }
}