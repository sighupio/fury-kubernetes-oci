resource "oci_identity_user" "volume-driver" {
  compartment_id = "${var.tenancy_ocid}"
  description    = "This user is created and managed by Terraform"
  name           = "volume-driver-${var.name}-${var.env}"

  freeform_tags = {
    "Owner" = "Terraform"
  }
}

resource "oci_identity_group" "volume-driver" {
  compartment_id = "${var.tenancy_ocid}"
  description    = "This group is created and managed by Terraform"
  name           = "volume-driver-${var.name}-${var.env}"

  freeform_tags = {
    "Owner" = "Terraform"
  }
}

resource "oci_identity_user_group_membership" "volume-driver" {
  group_id = "${oci_identity_group.volume-driver.id}"
  user_id  = "${oci_identity_user.volume-driver.id}"
}

resource "oci_identity_policy" "volume-driver" {
  compartment_id = "${var.tenancy_ocid}"
  description    = "This policy is created and managed by terraform"
  name           = "volume-driver-${var.name}-${var.env}"

  statements = [
    "Allow group ${oci_identity_group.volume-driver.name} to read vnic-attachments in compartment id ${var.compartment-id}",
    "Allow group ${oci_identity_group.volume-driver.name} to read vnics in compartment id ${var.network-compartment-id}",
    "Allow group ${oci_identity_group.volume-driver.name} to read instances in compartment id ${var.compartment-id}",
    "Allow group ${oci_identity_group.volume-driver.name} to read subnets in compartment id ${var.network-compartment-id}",
    "Allow group ${oci_identity_group.volume-driver.name} to use volumes in compartment id ${var.compartment-id}",
    "Allow group ${oci_identity_group.volume-driver.name} to use instances in compartment id ${var.compartment-id}",
    "Allow group ${oci_identity_group.volume-driver.name} to manage volume-attachments in compartment id ${var.compartment-id}",
  ]

  freeform_tags = {
    "Owner" = "Terraform"
  }
}

resource "tls_private_key" "volume-driver" {
  algorithm = "RSA"
  rsa_bits  = "2048"
}

resource "oci_identity_api_key" "volume-driver" {
  key_value = "${tls_private_key.volume-driver.public_key_pem}"
  user_id   = "${oci_identity_user.volume-driver.id}"
}

locals {
  oci-volume-driver = <<EOF
apiVersion: v1
stringData:
  config.yaml: |-
    auth:
      tenancy: ${var.tenancy_ocid}
      user: ${oci_identity_user.volume-driver.id}
      key: |
        ${indent(8, tls_private_key.volume-driver.private_key_pem)}
      fingerprint: ${oci_identity_api_key.volume-driver.fingerprint}
      region: ${var.region}
      vcn: ${var.vcn-id}
    compartment: ${var.compartment-id}
kind: Secret
metadata:
  name: oci-flexvolume-driver
  namespace: kube-system
type: Opaque
EOF
}

output "oci-volume-driver" {
  value = "${local.oci-volume-driver}"
}
