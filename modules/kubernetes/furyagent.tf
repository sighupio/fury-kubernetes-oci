resource "oci_objectstorage_bucket" "furyagent" {
  compartment_id = "${var.compartment-id}"
  name           = "${var.name}-${var.env}-furyagent"
  namespace      = "${var.object-storage-namespace}"

  freeform_tags = {
    "Owner" = "Terraform"
  }
}

resource "oci_identity_user" "furyagent" {
  compartment_id = "${var.tenancy_ocid}"
  description    = "This user is created and managed by Terraform"
  name           = "${oci_objectstorage_bucket.furyagent.name}"

  freeform_tags = {
    "Owner" = "Terraform"
  }
}

resource "oci_identity_group" "furyagent" {
  compartment_id = "${var.tenancy_ocid}"
  description    = "This group is created and managed by Terraform"
  name           = "${oci_objectstorage_bucket.furyagent.name}"

  freeform_tags = {
    "Owner" = "Terraform"
  }
}

resource "oci_identity_user_group_membership" "furyagent" {
  group_id = "${oci_identity_group.furyagent.id}"
  user_id  = "${oci_identity_user.furyagent.id}"
}

resource "oci_identity_customer_secret_key" "furyagent" {
  display_name = "furyagent"
  user_id      = "${oci_identity_user.furyagent.id}"
}

resource "oci_identity_policy" "furyagent" {
  #Required
  compartment_id = "${var.tenancy_ocid}"
  description    = "This policy is created and managed by terraform"
  name           = "${oci_objectstorage_bucket.furyagent.name}"

  statements = [
    "Allow group ${oci_identity_group.furyagent.name} to read buckets in compartment id ${var.compartment-id}",
    "Allow group ${oci_identity_group.furyagent.name} to manage objects in compartment id ${var.compartment-id} where all {target.bucket.name='${oci_objectstorage_bucket.furyagent.name}'}",
  ]

  #Optional
  freeform_tags = {
    "Owner" = "Terraform"
  }
}

locals {
  furyagent = <<EOF
storage:
  provider: s3
  aws_access_key: ${oci_identity_customer_secret_key.furyagent.id}
  aws_secret_key: ${oci_identity_customer_secret_key.furyagent.key}
  bucketName: "${oci_objectstorage_bucket.furyagent.name}"
  url: https://${var.object-storage-namespace}.compat.objectstorage.${var.region}.oraclecloud.com
  region: ${var.region}
clusterComponent:
  nodeName:
  master:
    certDir: ${path.root}
    caCertFilename: ca.crt
    caKeyFilename: ca.key
    saPubFilename: sa.pub
    saKeyFilename: sa.key
    proxyCaCertFilename: front-proxy-ca.crt
    proxyKeyCertFilename: front-proxy-ca.key
EOF

  furyagent_ansible_secrets = <<EOF
---

aws_access_key: ${oci_identity_customer_secret_key.furyagent.id}
aws_secret_key: "${oci_identity_customer_secret_key.furyagent.key}"
aws_region: "${var.region}"
s3_bucket_name: "${oci_objectstorage_bucket.furyagent.name}"
s3_endpooint: "https://${var.object-storage-namespace}.compat.objectstorage.${var.region}.oraclecloud.com"
EOF
}

output "furyagent" {
  value = "${local.furyagent}"
}

output "furyagent_ansible_secrets" {
  value = "${local.furyagent_ansible_secrets}"
}
