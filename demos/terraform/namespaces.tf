resource "kubernetes_namespace" "namespace" {
  depends_on = ["google_container_cluster.primary"]
  count      = "${var.namespace_count}"

  metadata {
    name = "namespace${count.index}"
  }
}
