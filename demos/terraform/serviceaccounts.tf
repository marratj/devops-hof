resource "kubernetes_service_account" "serviceaccount" {
  depends_on = ["kubernetes_namespace.namespace"]
  count      = "${var.namespace_count}"

  metadata {
    name      = "serviceaccount${count.index}"
    namespace = "namespace${count.index}"
  }
}

resource "kubernetes_role_binding" "role_binding" {
  depends_on = ["kubernetes_service_account.serviceaccount"]
  count      = "${var.namespace_count}"

  metadata {
    name      = "serviceaccount${count.index}"
    namespace = "namespace${count.index}"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "admin"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "serviceaccount${count.index}"
    namespace = "namespace${count.index}"
  }
}

data "kubernetes_secret" "serviceaccountkey" {
  depends_on = ["kubernetes_service_account.serviceaccount"]
  count      = "${var.namespace_count}"

  metadata {
    name      = "${kubernetes_service_account.serviceaccount.*.default_secret_name[count.index]}"
    namespace = "namespace${count.index}"
  }
}

resource "local_file" "serviceaccountkey" {
  count      = "${var.namespace_count}"
  filename =  "serviceaccount${count.index}"
  content = <<EOF
apiVersion: v1
kind: Config
clusters:
- name: default-cluster
  cluster:
    certificate-authority-data: ${google_container_cluster.primary.master_auth.0.cluster_ca_certificate}
    server: https://${google_container_cluster.primary.endpoint}
contexts:
- name: default-context
  context:
    cluster: default-cluster
    namespace: namespace${count.index}
    user: default-user
current-context: default-context
users:
- name: default-user
  user:
    token: ${lookup(data.kubernetes_secret.serviceaccountkey.*.data[count.index], "token")}
EOF
}
/*

resource "local_file" "serviceaccountkey" {
  count    = "${var.namespace_count}"
  filename = "serviceaccount${count.index}"
  content  = "${data.kubernetes_secret.serviceaccountkey.*.type[count.index]}"
} 
*/ 

output "secret_data" {
  value = "${data.kubernetes_secret.serviceaccountkey.*.data[0]}"
}
