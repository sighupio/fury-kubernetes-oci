locals {
  inventory = <<EOF
[bastion]
${join("\n", formatlist("%s ansible_host=%s kubernetes_node_ocid=%s", oci_core_instance.bastion.*.hostname_label, oci_core_instance.bastion.*.public_ip, oci_core_instance.bastion.*.id))}
[master]
${join("\n", formatlist("%s ansible_host=%s kubernetes_node_ocid=%s", oci_core_instance.master.*.hostname_label, oci_core_instance.master.*.private_ip, oci_core_instance.master.*.id))}
[infra]
${join("\n", formatlist("%s ansible_host=%s kubernetes_node_ocid=%s", oci_core_instance.infra.*.hostname_label, oci_core_instance.infra.*.private_ip, oci_core_instance.infra.*.id))}
[staging]
${join("\n", formatlist("%s ansible_host=%s kubernetes_node_ocid=%s", oci_core_instance.staging.*.hostname_label, oci_core_instance.staging.*.private_ip, oci_core_instance.staging.*.id))}
[production]
${join("\n", formatlist("%s ansible_host=%s kubernetes_node_ocid=%s", oci_core_instance.production.*.hostname_label, oci_core_instance.production.*.private_ip, oci_core_instance.production.*.id))}
[jenkins]
${join("\n", formatlist("%s ansible_host=%s", oci_core_instance.jenkins.*.hostname_label, oci_core_instance.jenkins.*.private_ip))}

[nodes:children]
infra
staging
production

[gated:children]
master
nodes
jenkins

[all:vars]
ansible_user=opc
ansible_ssh_private_key_file='${var.ssh-private-key}'
ansible_python_interpreter=python2

[master:vars]
etcd_initial_cluster='${join(",", formatlist("%s=https://%s.%s.%s.oraclevcn.com:2380", oci_core_instance.master.*.hostname_label, oci_core_instance.master.*.hostname_label, var.controlplane-subnet-dns-label, var.vcn-dns-label))}'
control_plane_endpoint=${oci_load_balancer_load_balancer.controlplane.ip_address_details.0.ip_address}
dns_zone=${var.controlplane-subnet-dns-label}.${var.vcn-dns-label}.oraclevcn.com

[gated:vars]
ansible_ssh_common_args='-o ProxyCommand="ssh -o StrictHostKeyChecking=no -W %h:%p -q -i ${var.ssh-private-key} opc@${oci_core_instance.bastion.*.public_ip[0]}"'
EOF
# public_lb_address=${oci_load_balancer_load_balancer.public.ip_address_details.0.ip_address}

  oci-flex-driver = <<EOF
apiVersion: v1
data:
  init.sh: |-
    #!/bin/sh

    kubectl config --kubeconfig=/files/kubeconfig set-cluster oci-cluster --server=https://${oci_load_balancer_load_balancer.controlplane.ip_address_details.0.ip_address}:6443 --certificate-authority=/run/secrets/kubernetes.io/serviceaccount/ca.crt --embed-certs=true
    kubectl config --kubeconfig=/files/kubeconfig set-credentials oci-user --token=$(cat /run/secrets/kubernetes.io/serviceaccount/token)
    kubectl config --kubeconfig=/files/kubeconfig set-context oci-flex --user=oci-user --cluster=oci-cluster
    kubectl config --kubeconfig=/files/kubeconfig use-context oci-flex
kind: ConfigMap
metadata:
  name: initscript
  namespace: kube-system
EOF
}

output "inventory" {
  value = "${local.inventory}"
}

output "oci-flex-driver" {
  value = "${local.oci-flex-driver}"
}
