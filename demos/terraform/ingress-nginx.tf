resource "null_resource" "ingress-nginx" {
  depends_on = ["google_container_cluster.primary"]

  provisioner "local-exec" {
    command = "kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/nginx-0.24.0/deploy/mandatory.yaml"
  }

  provisioner "local-exec" {
    command = "kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/nginx-0.24.0/deploy/provider/cloud-generic.yaml"
  }

  provisioner "local-exec" {
    command = "kubectl delete -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/nginx-0.24.0/deploy/provider/cloud-generic.yaml"
    when    = "destroy"
  }

  provisioner "local-exec" {
    command = "kubectl delete -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/nginx-0.24.0/deploy/mandatory.yaml"
    when    = "destroy"
  }
}
