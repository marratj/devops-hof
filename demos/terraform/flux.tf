resource "null_resource" "flux" {
  depends_on = ["google_container_cluster.primary"]

  provisioner "local-exec" {
      command = "kubectl apply -f ../kubernetes/flux"
  }
}
