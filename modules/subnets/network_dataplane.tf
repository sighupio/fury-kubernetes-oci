resource "oci_core_subnet" "dataplane" {
  vcn_id                     = "${var.vcn-id}"
  display_name               = "${var.subnet-name-prefix}-dataplane"
  compartment_id             = "${var.compartment-id}"
  cidr_block                 = "${var.dataplane-cidr}"
  security_list_ids          = ["${oci_core_security_list.dataplane.id}"]
  route_table_id             = "${oci_core_route_table.dataplane.id}"
  dhcp_options_id            = "${oci_core_dhcp_options.main.id}"
  dns_label                  = "${var.subnet-prefix-dns}dataplane"
  prohibit_public_ip_on_vnic = "true"
}

resource "oci_core_route_table" "dataplane" {
  vcn_id         = "${var.vcn-id}"
  display_name   = "${var.subnet-name-prefix}-dataplane"
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

resource "oci_core_security_list" "dataplane" {
  vcn_id         = "${var.vcn-id}"
  display_name   = "${var.subnet-name-prefix}-dataplane"
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

  egress_security_rules {
    destination      = "0.0.0.0/0"
    protocol         = "all"
    destination_type = "CIDR_BLOCK"
  }

  // External http ingress
  ingress_security_rules {
    protocol    = "6"
    source      = "${var.public-cidr}"
    source_type = "CIDR_BLOCK"

    tcp_options {
      max = "31080"
      min = "31080"
    }
  }

  // External https ingress
  ingress_security_rules {
    protocol    = "6"
    source      = "${var.public-cidr}"
    source_type = "CIDR_BLOCK"

    tcp_options {
      max = "31443"
      min = "31443"
    }
  }

  // TO ADD MORE FINE GRAINED POLICIES ONCE ALL THE COMPONENTS ARE DEPLOYED
  ingress_security_rules {
    protocol    = "all"
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
  }
}
