resource "oci_objectstorage_bucket" "velero" {
  compartment_id = "${var.compartment-id}"
  name           = "${var.name}-${var.env}-velero"
  namespace      = "${var.object-storage-namespace}"

  freeform_tags = {
    "Owner" = "Terraform"
  }
}

resource "oci_identity_user" "velero" {
  compartment_id = "${var.tenancy_ocid}"
  description    = "This user is created and managed by Terraform"
  name           = "${oci_objectstorage_bucket.velero.name}"

  freeform_tags = {
    "Owner" = "Terraform"
  }
}

resource "oci_identity_group" "velero" {
  compartment_id = "${var.tenancy_ocid}"
  description    = "This group is created and managed by Terraform"
  name           = "${oci_objectstorage_bucket.velero.name}"

  freeform_tags = {
    "Owner" = "Terraform"
  }
}

resource "oci_identity_user_group_membership" "velero" {
  group_id = "${oci_identity_group.velero.id}"
  user_id  = "${oci_identity_user.velero.id}"
}

resource "oci_identity_customer_secret_key" "velero" {
  display_name = "velero"
  user_id      = "${oci_identity_user.velero.id}"
}

resource "oci_identity_policy" "velero" {
  #Required
  compartment_id = "${var.tenancy_ocid}"
  description    = "This policy is created and managed by terraform"
  name           = "${oci_objectstorage_bucket.velero.name}"

  statements = [
    "Allow group ${oci_identity_group.velero.name} to read buckets in compartment id ${var.compartment-id}",
    "Allow group ${oci_identity_group.velero.name} to manage objects in compartment id ${var.compartment-id} where all {target.bucket.name='${oci_objectstorage_bucket.velero.name}'}",
  ]

  #Optional
  freeform_tags = {
    "Owner" = "Terraform"
  }
}

locals {
  velero = <<EOF
apiVersion: ark.heptio.com/v1
kind: BackupStorageLocation
metadata:
  name: default
spec:
  provider: aws
  objectStorage:
    bucket: ${oci_objectstorage_bucket.velero.name}
  config:
    region: ${var.region}
    s3ForcePathStyle: "true"
    s3Url: https://${var.object-storage-namespace}.compat.objectstorage.${var.region}.oraclecloud.com
---
apiVersion: ark.heptio.com/v1
kind: VolumeSnapshotLocation
metadata:
  name: default
spec:
  provider: aws
  config:
    region: ${var.region}
---
apiVersion: v1
stringData:
  cloud: |-
    [default]
    aws_access_key_id=${oci_identity_customer_secret_key.velero.id}
    aws_secret_access_key=${oci_identity_customer_secret_key.velero.key}
kind: Secret
metadata:
  name: cloud-credentials
  namespace: kube-system
type: Opaque
EOF
}

output "velero" {
  value = "${local.velero}"
}
