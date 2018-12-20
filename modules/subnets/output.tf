output controlplane-subnet-id {
  value = "${oci_core_subnet.controlplane.id}"
}

output dataplane-subnet-id {
  value = "${oci_core_subnet.dataplane.id}"
}

output public-subnet-id {
  value = "${oci_core_subnet.public.id}"
}

output controlplane-subnet-dns-label {
  value = "${oci_core_subnet.controlplane.dns_label}"
}
