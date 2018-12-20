resource "oci_identity_user" "volume-provisioner" {
  compartment_id = "${var.tenancy_ocid}"
  description    = "This user is created and managed by Terraform"
  name           = "volume-provisioner-${var.name}-${var.env}"

  freeform_tags = {
    "Owner" = "Terraform"
  }
}

resource "oci_identity_group" "volume-provisioner" {
  compartment_id = "${var.tenancy_ocid}"
  description    = "This group is created and managed by Terraform"
  name           = "volume-provisioner-${var.name}-${var.env}"

  freeform_tags = {
    "Owner" = "Terraform"
  }
}

resource "oci_identity_user_group_membership" "volume-provisioner" {
  group_id = "${oci_identity_group.volume-provisioner.id}"
  user_id  = "${oci_identity_user.volume-provisioner.id}"
}

resource "oci_identity_policy" "volume-provisioner" {
  #Required
  compartment_id = "${var.compartment-id}"
  description    = "This policy is created and managed by terraform"
  name           = "volume-provisioner-${var.name}-${var.env}"

  statements = [
    "Allow group ${oci_identity_group.volume-provisioner.name} to manage volumes in compartment id ${var.compartment-id}",
    "Allow group ${oci_identity_group.volume-provisioner.name} to manage filesystems in compartment id ${var.compartment-id}",
  ]

  freeform_tags = {
    "Owner" = "Terraform"
  }
}

resource "tls_private_key" "volume-provisioner" {
  algorithm = "RSA"
  rsa_bits  = "2048"
}

resource "oci_identity_api_key" "volume-provisioner" {
  key_value = "${tls_private_key.volume-provisioner.public_key_pem}"
  user_id   = "${oci_identity_user.volume-provisioner.id}"
}

locals {
  oci-volume-provisioner = <<EOF
apiVersion: v1
stringData:
  config.yaml: |-
    auth:
      tenancy: ${var.tenancy_ocid}
      user: ${oci_identity_user.volume-provisioner.id}
      key: |
        ${indent(8, tls_private_key.volume-provisioner.private_key_pem)}
      fingerprint: ${oci_identity_api_key.volume-provisioner.fingerprint}
      region: ${var.region}
    compartment: ${var.compartment-id}
kind: Secret
metadata:
  name: oci-volume-provisioner
  namespace: kube-system
type: Opaque
EOF
}

output "oci-volume-provisioner" {
  value = "${local.oci-volume-provisioner}"
}
