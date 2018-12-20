resource "oci_core_instance" "infra" {
  count               = "${var.infra-machine-count}"
  availability_domain = "${lookup(data.oci_identity_availability_domains.main.availability_domains[count.index % length(data.oci_identity_availability_domains.main.availability_domains)], "name")}"
  compartment_id      = "${var.compartment-id}"
  shape               = "${var.infra-machine-type}"

  create_vnic_details {
    subnet_id        = "${var.dataplane-subnet-id}"
    assign_public_ip = "false"
  }

  display_name   = "infra-${var.env}-${count.index+1}"
  hostname_label = "infra-${var.env}-${count.index+1}"

  metadata {
    ssh_authorized_keys = "${file(var.ssh-public-key-path)}"
  }

  source_details {
    source_id               = "${var.ol-image-ocid}"
    source_type             = "image"
    boot_volume_size_in_gbs = "100"
  }

  preserve_boot_volume = true

  defined_tags = "${map("${oci_identity_tag_namespace.main.name}.${var.tag-namespace-key}", "infra" )}"
}

resource "oci_core_instance" "staging" {
  count               = "${var.staging-machine-count}"
  availability_domain = "${lookup(data.oci_identity_availability_domains.main.availability_domains[count.index % length(data.oci_identity_availability_domains.main.availability_domains)], "name")}"
  compartment_id      = "${var.compartment-id}"
  shape               = "${var.staging-machine-type}"

  create_vnic_details {
    subnet_id        = "${var.dataplane-subnet-id}"
    assign_public_ip = "false"
  }

  display_name   = "staging-${var.env}-${count.index+1}"
  hostname_label = "staging-${var.env}-${count.index+1}"

  metadata {
    ssh_authorized_keys = "${file(var.ssh-public-key-path)}"
  }

  source_details {
    source_id               = "${var.ol-image-ocid}"
    source_type             = "image"
    boot_volume_size_in_gbs = "100"
  }

  preserve_boot_volume = true
  defined_tags         = "${map("${oci_identity_tag_namespace.main.name}.${var.tag-namespace-key}", "staging" )}"
}

resource "oci_core_instance" "production" {
  count               = "${var.production-machine-count}"
  availability_domain = "${lookup(data.oci_identity_availability_domains.main.availability_domains[count.index % length(data.oci_identity_availability_domains.main.availability_domains)], "name")}"
  compartment_id      = "${var.compartment-id}"
  shape               = "${var.production-machine-type}"

  create_vnic_details {
    subnet_id        = "${var.dataplane-subnet-id}"
    assign_public_ip = "false"
  }

  display_name   = "production-${var.env}-${count.index+1}"
  hostname_label = "production-${var.env}-${count.index+1}"

  metadata {
    ssh_authorized_keys = "${file(var.ssh-public-key-path)}"
  }

  source_details {
    source_id               = "${var.ol-image-ocid}"
    source_type             = "image"
    boot_volume_size_in_gbs = "100"
  }

  preserve_boot_volume = true
  defined_tags         = "${map("${oci_identity_tag_namespace.main.name}.${var.tag-namespace-key}", "production" )}"
}
