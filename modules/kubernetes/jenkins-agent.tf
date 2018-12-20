resource "oci_core_instance" "jenkins" {
  count               = "${var.jenkins-machine-count}"
  availability_domain = "${lookup(data.oci_identity_availability_domains.main.availability_domains[count.index % length(data.oci_identity_availability_domains.main.availability_domains)], "name")}"
  compartment_id      = "${var.compartment-id}"
  shape               = "${var.jenkins-machine-type}"

  create_vnic_details {
    subnet_id        = "${var.dataplane-subnet-id}"
    assign_public_ip = "false"
  }

  display_name   = "jenkins-${count.index+1}"
  hostname_label = "jenkins-${count.index+1}"

  metadata {
    ssh_authorized_keys = "${file(var.ssh-public-key-path)}"
  }

  source_details {
    source_id               = "${var.ubuntu-image-ocid}"
    source_type             = "image"
    boot_volume_size_in_gbs = "200"
  }

  preserve_boot_volume = true
  defined_tags         = "${map("${oci_identity_tag_namespace.main.name}.${var.tag-namespace-key}", "jenkins" )}"
}
