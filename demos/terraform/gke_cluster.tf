resource "google_container_cluster" "primary" {
  name               = "${var.cluster_name}"
  zone               = "${var.cluster_zone}"
  initial_node_count = "${var.cluster_node_count}"
  project            = "${var.cluster_project}"

  master_auth {
      username = ""
      password = ""
      client_certificate_config {
        issue_client_certificate = false
      }
  }

  min_master_version = "1.11.2-gke.18"

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]

    tags = ["devops", "hof"]
  }

# get credentials via gcloud after cluster the cluster
  provisioner "local-exec" {
    command = "export KUBECONFIG=$(pwd)/kubeconfig; gcloud container clusters get-credentials ${google_container_cluster.primary.name} --project ${var.cluster_project} --zone ${var.cluster_zone}"
  }

  provisioner "local-exec" {
      command = "kubectl create clusterrolebinding \"cluster-admin-$(whoami)\" --clusterrole=cluster-admin --user=\"$(gcloud config get-value core/account)\""
  }
}
