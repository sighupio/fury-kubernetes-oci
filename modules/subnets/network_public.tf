resource "oci_core_subnet" "public" {
  vcn_id                     = "${var.vcn-id}"
  display_name               = "${var.subnet-name-prefix}-public"
  compartment_id             = "${var.compartment-id}"
  cidr_block                 = "${var.public-cidr}"
  security_list_ids          = ["${oci_core_security_list.public.id}"]
  route_table_id             = "${oci_core_route_table.public.id}"
  dhcp_options_id            = "${oci_core_dhcp_options.main.id}"
  dns_label                  = "${var.subnet-prefix-dns}public"
  prohibit_public_ip_on_vnic = "false"
}

resource "oci_core_route_table" "public" {
  vcn_id         = "${var.vcn-id}"
  display_name   = "${var.subnet-name-prefix}-public"
  compartment_id = "${var.compartment-id}"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = "${var.internet-gateway-id}"
  }
}

resource "oci_core_dhcp_options" "main" {
  vcn_id         = "${var.vcn-id}"
  display_name   = "${var.subnet-name-prefix}-main"
  compartment_id = "${var.compartment-id}"

  options {
    type               = "DomainNameServer"
    server_type        = "CustomDnsServer"
    custom_dns_servers = ["${var.custom-dns}"]
  }

  options {
    type                = "SearchDomain"
    search_domain_names = ["${var.search-domain}"]
  }
}

resource "oci_core_dhcp_options" "master" {
  vcn_id         = "${var.vcn-id}"
  display_name   = "${var.subnet-name-prefix}-masters"
  compartment_id = "${var.compartment-id}"

  options {
    type        = "DomainNameServer"
    server_type = "VcnLocalPlusInternet"
  }

  options {
    type                = "SearchDomain"
    search_domain_names = ["${var.vcn-dns-label}.oraclevcn.com"]
  }
}

resource "oci_core_security_list" "public" {
  vcn_id         = "${var.vcn-id}"
  display_name   = "${var.subnet-name-prefix}-public"
  compartment_id = "${var.compartment-id}"

  ingress_security_rules {
    protocol    = "all"
    source      = "${var.public-cidr}"
    source_type = "CIDR_BLOCK"
  }

  ingress_security_rules {
    protocol    = "6"
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"

    tcp_options {
      max = "22"
      min = "22"
    }
  }

  egress_security_rules {
    destination      = "0.0.0.0/0"
    protocol         = "all"
    destination_type = "CIDR_BLOCK"
  }
}
