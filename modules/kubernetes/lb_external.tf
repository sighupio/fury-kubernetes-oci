// resource "oci_load_balancer_load_balancer" "public" {
//   #Required
//   compartment_id = "${var.compartment-id}"
//   display_name   = "public-${var.name}-${var.env}"
//   shape          = "${var.load_balancer_shape}"
//   subnet_ids     = ["${var.public-subnet-id}"]
//   #Optional
//   freeform_tags = {
//     "Owner" = "Terraform"
//   }
//   is_private = "false"
// }
// ## ------------------------------------     LISTENER PER WORKERS INGRESS EXTERNAL HTTP ------------------------------------
// resource "oci_load_balancer_listener" "external-http" {
//   load_balancer_id         = "${oci_load_balancer_load_balancer.public.id}"
//   name                     = "external-http-${var.name}-${var.env}"
//   port                     = "80"
//   protocol                 = "TCP"
//   default_backend_set_name = "${oci_load_balancer_backend_set.external-http.name}"
//   connection_configuration {
//     idle_timeout_in_seconds = "60"
//   }
// }
// resource "oci_load_balancer_backend_set" "external-http" {
//   health_checker {
//     protocol          = "TCP"
//     interval_ms       = "5000"
//     port              = "31080"
//     timeout_in_millis = "2000"
//   }
//   load_balancer_id = "${oci_load_balancer_load_balancer.public.id}"
//   name             = "external-http-${var.name}-${var.env}"
//   policy           = "LEAST_CONNECTIONS"
// }
// resource "oci_load_balancer_backend" "external-http" {
//   count            = "${var.infra-machine-count}"
//   backendset_name  = "${oci_load_balancer_backend_set.external-http.name}"
//   ip_address       = "${element(oci_core_instance.infra.*.private_ip, count.index)}"
//   load_balancer_id = "${oci_load_balancer_load_balancer.public.id}"
//   port             = "31080"
// }
// ## ------------------------------------     LISTENER PER WORKERS INGRESS EXTERNAL HTTPS ------------------------------------
// resource "oci_load_balancer_listener" "external-https" {
//   load_balancer_id         = "${oci_load_balancer_load_balancer.public.id}"
//   name                     = "external-https-${var.name}-${var.env}"
//   port                     = "443"
//   protocol                 = "TCP"
//   default_backend_set_name = "${oci_load_balancer_backend_set.external-https.name}"
//   connection_configuration {
//     idle_timeout_in_seconds = "60"
//   }
// }
// resource "oci_load_balancer_backend_set" "external-https" {
//   health_checker {
//     protocol          = "TCP"
//     interval_ms       = "5000"
//     port              = "31443"
//     timeout_in_millis = "2000"
//   }
//   load_balancer_id = "${oci_load_balancer_load_balancer.public.id}"
//   name             = "external-https-${var.name}-${var.env}"
//   policy           = "LEAST_CONNECTIONS"
// }
// resource "oci_load_balancer_backend" "external-https" {
//   count            = "${var.infra-machine-count}"
//   backendset_name  = "${oci_load_balancer_backend_set.external-https.name}"
//   ip_address       = "${element(oci_core_instance.infra.*.private_ip, count.index)}"
//   load_balancer_id = "${oci_load_balancer_load_balancer.public.id}"
//   port             = "31443"
// }

