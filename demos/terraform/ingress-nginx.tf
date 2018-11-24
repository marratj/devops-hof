resource "null_resource" "ingress-nginx" {
  depends_on = ["google_container_cluster.primary"]

  provisioner "local-exec" {
      command = "kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/mandatory.yaml"
  }
  provisioner "local-exec" {
      command = "kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/provider/cloud-generic.yaml"
  }
}
