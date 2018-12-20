resource "oci_core_instance" "master" {
  count               = "${var.master-machine-count}"
  availability_domain = "${lookup(data.oci_identity_availability_domains.main.availability_domains[count.index % length(data.oci_identity_availability_domains.main.availability_domains)], "name")}"
  compartment_id      = "${var.compartment-id}"
  shape               = "${var.master-machine-type}"

  create_vnic_details {
    subnet_id        = "${var.controlplane-subnet-id}"
    assign_public_ip = "false"
  }

  display_name   = "master-${var.env}-${count.index+1}"
  hostname_label = "master-${var.env}-${count.index+1}"

  // fault_domain = "${var.instance_fault_domain}"

  metadata {
    ssh_authorized_keys = "${file(var.ssh-public-key-path)}"
  }
  source_details {
    source_id               = "${var.ol-image-ocid}"
    source_type             = "image"
    boot_volume_size_in_gbs = "100"
  }
  preserve_boot_volume = true
}
