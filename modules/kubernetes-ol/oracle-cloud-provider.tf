resource "oci_identity_user" "oci-provider" {
  compartment_id = "${var.tenancy_ocid}"
  description    = "This user is created and managed by Terraform"
  name           = "oci-provider-${var.name}-${var.env}"

  freeform_tags = {
    "Owner" = "Terraform"
  }
}

resource "oci_identity_group" "oci-provider" {
  compartment_id = "${var.tenancy_ocid}"
  description    = "This group is created and managed by Terraform"
  name           = "oci-provider-${var.name}-${var.env}"

  freeform_tags = {
    "Owner" = "Terraform"
  }
}

resource "oci_identity_user_group_membership" "oci-provider" {
  group_id = "${oci_identity_group.oci-provider.id}"
  user_id  = "${oci_identity_user.oci-provider.id}"
}

resource "oci_identity_policy" "oci-provider" {
  compartment_id = "${var.tenancy_ocid}"
  description    = "This policy is created and managed by terraform"
  name           = "oci-provider-${var.name}-${var.env}"

  statements = [
    "Allow group ${oci_identity_group.oci-provider.name} to manage load-balancers in compartment id ${var.compartment-id}",
    "Allow group ${oci_identity_group.oci-provider.name} to use security-lists in compartment id ${var.compartment-id}",
    "Allow group ${oci_identity_group.oci-provider.name} to read instances in compartment id ${var.compartment-id}",
    "Allow group ${oci_identity_group.oci-provider.name} to read subnets in compartment id ${var.network-compartment-id}",
    "Allow group ${oci_identity_group.oci-provider.name} to read vnics in compartment id ${var.network-compartment-id}",
    "Allow group ${oci_identity_group.oci-provider.name} to read vnic-attachments in compartment id ${var.compartment-id}",
  ]

  freeform_tags = {
    "Owner" = "Terraform"
  }
}

resource "tls_private_key" "oci-provider" {
  algorithm = "RSA"
  rsa_bits  = "2048"
}

resource "oci_identity_api_key" "oci-provider" {
  key_value = "${tls_private_key.oci-provider.public_key_pem}"
  user_id   = "${oci_identity_user.oci-provider.id}"
}

locals {
  oci-oci-provider = <<EOF
apiVersion: v1
stringData:
  cloud-provider.yaml: |-
    auth:
      tenancy: ${var.tenancy_ocid}
      user: ${oci_identity_user.oci-provider.id}
      key: |
        ${indent(8, tls_private_key.oci-provider.private_key_pem)}
      fingerprint: ${oci_identity_api_key.oci-provider.fingerprint}
      region: ${var.region}
    compartment: ${var.compartment-id}
    vcn: ${var.vcn-id}
    loadBalancer:
      disabled: true
    rateLimiter:
      rateLimitQPSRead: 20.0
      rateLimitBucketRead: 5
      rateLimitQPSWrite: 20.0
      rateLimitBucketWrite: 5
kind: Secret
metadata:
  name: oci-cloud-controller-manager
  namespace: kube-system
type: Opaque
EOF
}

output "oci-oci-provider" {
  value = "${local.oci-oci-provider}"
}
