resource "oci_identity_user" "jenkins-pusher" {
  compartment_id = "${var.tenancy_ocid}"
  description    = "This user is created and managed by Terraform"
  name           = "jenkins-pusher-${var.name}"

  freeform_tags = {
    "Owner" = "Terraform"
  }
}

resource "oci_identity_group" "jenkins-pusher" {
  compartment_id = "${var.tenancy_ocid}"
  description    = "This group is created and managed by Terraform"
  name           = "jenkins-pusher-${var.name}"

  freeform_tags = {
    "Owner" = "Terraform"
  }
}

resource "oci_identity_user_group_membership" "jenkins-pusher" {
  group_id = "${oci_identity_group.jenkins-pusher.id}"
  user_id  = "${oci_identity_user.jenkins-pusher.id}"
}

resource "oci_identity_policy" "jenkins-pusher" {
  #Required
  compartment_id = "${var.tenancy_ocid}"
  description    = "This policy is created and managed by terraform"
  name           = "jenkins-pusher-${var.name}"

  statements = [
    "Allow group ${oci_identity_group.jenkins-pusher.name} to use repos in tenancy",
    "Allow group ${oci_identity_group.jenkins-pusher.name} to manage repos in tenancy where ANY {request.permission = 'REPOSITORY_CREATE', request.permission = 'REPOSITORY_UPDATE'}",
  ]

  freeform_tags = {
    "Owner" = "Terraform"
  }
}

resource "oci_identity_auth_token" "jenkins-pusher" {
  description = "Used to push images from Jenkins"
  user_id     = "${oci_identity_user.jenkins-pusher.id}"
}

locals {
  jenkins-pusher = <<EOF
registry: fra.ocir.io/${var.ocir-namespace}
username: ${var.ocir-namespace}/jenkins-pusher-${var.name}
password: ${oci_identity_auth_token.jenkins-pusher.token}
EOF
}

output "jenkins-pusher" {
  value = "${local.jenkins-pusher}"
}
