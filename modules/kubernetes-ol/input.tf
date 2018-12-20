variable name {}
variable env {}
variable region {}
variable tenancy_ocid {}
variable public-subnet-id {}
variable dataplane-subnet-id {}
variable controlplane-subnet-id {}
variable compartment-id {}
variable vcn-dns-label {}
variable vcn-id {}
variable controlplane-subnet-dns-label {}

variable load_balancer_shape {
  default = "400Mbps"
}

variable ol-image-ocid {}

# BASTION CONFIGURATIONS
variable "bastion-count" {
  default = 1
}

variable "ssh-private-key" {}

variable "bastion-machine-type" {
  default = "VM.Standard1.1"
}

variable "bastion-ssh-enabled" {
  type        = "string"
  default     = true
  description = "disabling this will block all the INGRESS traffic on port 22 of the bastion instances"
}

variable "ssh-public-key-path" {
  type = "string"
}

# DATA 
data "oci_identity_availability_domains" "main" {
  compartment_id = "${var.tenancy_ocid}"
}

variable "master-machine-type" {}

variable "master-machine-count" {
  default = 3
}

variable "production-machine-type" {}
variable "production-machine-count" {}
variable "staging-machine-count" {}
variable "staging-machine-type" {}
variable "infra-machine-count" {}
variable "infra-machine-type" {}

variable "jenkins-machine-count" {
  default = "1"
}

variable "jenkins-machine-type" {
  default = "VM.Standard1.4"
}

variable object-storage-namespace {}

resource "oci_identity_tag_namespace" "main" {
  compartment_id = "${var.compartment-id}"
  description    = "Namespace to separate instance roles"
  name           = "machinekind"
  is_retired     = false
}

variable tag-namespace-key {
  default = "type"
}

variable compartment-name {}
variable network-compartment-id {}

variable ocir-namespace {}
