resource "oci_core_subnet" "controlplane" {
  vcn_id                     = "${var.vcn-id}"
  display_name               = "${var.subnet-name-prefix}-controlplane"
  compartment_id             = "${var.compartment-id}"
  cidr_block                 = "${var.controlplane-cidr}"
  security_list_ids          = ["${oci_core_security_list.controlplane.id}"]
  route_table_id             = "${oci_core_route_table.controlplane.id}"
  dhcp_options_id            = "${oci_core_dhcp_options.master.id}"
  dns_label                  = "${var.subnet-prefix-dns}controlplane"
  prohibit_public_ip_on_vnic = "true"
}

resource "oci_core_route_table" "controlplane" {
  vcn_id         = "${var.vcn-id}"
  display_name   = "${var.subnet-name-prefix}-controlplane"
  compartment_id = "${var.compartment-id}"

  route_rules = [
    {
      destination       = "0.0.0.0/0"
      destination_type  = "CIDR_BLOCK"
      network_entity_id = "${var.nat-gateway-id}"
    },
    "${var.on-premise-routes}",
  ]
}

resource "oci_core_security_list" "controlplane" {
  vcn_id         = "${var.vcn-id}"
  display_name   = "${var.subnet-name-prefix}-controlplane"
  compartment_id = "${var.compartment-id}"

  ingress_security_rules {
    protocol    = "all"
    source      = "${var.controlplane-cidr}"
    source_type = "CIDR_BLOCK"
  }

  ingress_security_rules {
    protocol    = "all"
    source      = "${var.dataplane-cidr}"
    source_type = "CIDR_BLOCK"
  }

  // TO ADD MORE FINE GRAINED POLICIES ONCE ALL THE COMPONENTS ARE DEPLOYED
  ingress_security_rules {
    protocol    = "all"
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
  }

  egress_security_rules {
    destination      = "0.0.0.0/0"
    protocol         = "all"
    destination_type = "CIDR_BLOCK"
  }
}
