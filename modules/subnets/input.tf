variable "compartment-id" {}
variable "vcn-id" {}
variable "public-cidr" {}
variable "controlplane-cidr" {}
variable "dataplane-cidr" {}
variable "subnet-name-prefix" {}
variable "internet-gateway-id" {}
variable "nat-gateway-id" {}
variable "vcn-dns-label" {}

variable "on-premise-routes" {
  type = "list"
}

variable "search-domain" {}

variable "custom-dns" {
  type = "list"
}
