resource "oci_load_balancer_load_balancer" "controlplane" {
  compartment_id = "${var.compartment-id}"
  display_name   = "controlplane-${var.name}-${var.env}-${count.index}"
  shape          = "${var.load_balancer_shape}"
  subnet_ids     = ["${var.controlplane-subnet-id}"]

  freeform_tags = {
    "Owner" = "Terraform"
  }

  is_private = "true"
}

## ------------------------------------     LISTENER PER MASTERSSS  ------------------------------------
resource "oci_load_balancer_listener" "controlplane" {
  load_balancer_id         = "${oci_load_balancer_load_balancer.controlplane.id}"
  name                     = "master-${var.name}-${var.env}"
  port                     = "6443"
  protocol                 = "TCP"
  default_backend_set_name = "${oci_load_balancer_backend_set.controlplane.name}"

  connection_configuration {
    idle_timeout_in_seconds = "1200"
  }
}

resource "oci_load_balancer_backend_set" "controlplane" {
  health_checker {
    protocol          = "TCP"
    interval_ms       = "3000"
    port              = "6443"
    timeout_in_millis = "2000"
  }

  load_balancer_id = "${oci_load_balancer_load_balancer.controlplane.id}"
  name             = "master-${var.name}-${var.env}"
  policy           = "LEAST_CONNECTIONS"
}

resource "oci_load_balancer_backend" "controlplane" {
  count            = "${var.master-machine-count}"
  backendset_name  = "${oci_load_balancer_backend_set.controlplane.name}"
  ip_address       = "${element(oci_core_instance.master.*.private_ip, count.index)}"
  load_balancer_id = "${oci_load_balancer_load_balancer.controlplane.id}"
  port             = "6443"

  lifecycle {
    ignore_changes = ["ip_address"]
  }
}

## ------------------------------------     LISTENER PER WORKERS INGRESS INTERNAL  ------------------------------------
resource "oci_load_balancer_listener" "infra" {
  load_balancer_id         = "${oci_load_balancer_load_balancer.controlplane.id}"
  name                     = "infra-${var.name}-${var.env}"
  port                     = "80"
  protocol                 = "TCP"
  default_backend_set_name = "${oci_load_balancer_backend_set.infra.name}"

  connection_configuration {
    idle_timeout_in_seconds = "60"
  }
}

resource "oci_load_balancer_backend_set" "infra" {
  health_checker {
    protocol          = "TCP"
    interval_ms       = "5000"
    port              = "32080"
    timeout_in_millis = "2000"
  }

  load_balancer_id = "${oci_load_balancer_load_balancer.controlplane.id}"
  name             = "infra-${var.name}-${var.env}"
  policy           = "LEAST_CONNECTIONS"
}

resource "oci_load_balancer_backend" "infra" {
  count            = "${var.infra-machine-count}"
  backendset_name  = "${oci_load_balancer_backend_set.infra.name}"
  ip_address       = "${element(oci_core_instance.infra.*.private_ip, count.index)}"
  load_balancer_id = "${oci_load_balancer_load_balancer.controlplane.id}"
  port             = "32080"

  lifecycle {
    ignore_changes = ["ip_address"]
  }
}

## ------------------------------------     LISTENER PER JENKINS SLAVES  ------------------------------------
resource "oci_load_balancer_listener" "jenkins" {
  load_balancer_id         = "${oci_load_balancer_load_balancer.controlplane.id}"
  name                     = "jenkins-${var.name}-${var.env}"
  port                     = "50000"
  protocol                 = "TCP"
  default_backend_set_name = "${oci_load_balancer_backend_set.jenkins.name}"

  connection_configuration {
    idle_timeout_in_seconds = "60"
  }
}

resource "oci_load_balancer_backend_set" "jenkins" {
  health_checker {
    protocol          = "TCP"
    interval_ms       = "5000"
    port              = "31500"
    timeout_in_millis = "2000"
  }

  load_balancer_id = "${oci_load_balancer_load_balancer.controlplane.id}"
  name             = "jenkins-${var.name}-${var.env}"
  policy           = "LEAST_CONNECTIONS"
}

resource "oci_load_balancer_backend" "jenkins" {
  count            = "${var.infra-machine-count}"
  backendset_name  = "${oci_load_balancer_backend_set.jenkins.name}"
  ip_address       = "${element(oci_core_instance.infra.*.private_ip, count.index)}"
  load_balancer_id = "${oci_load_balancer_load_balancer.controlplane.id}"
  port             = "31500"

  lifecycle {
    ignore_changes = ["ip_address"]
  }
}

## ------------------------------------     LISTENER PER JENKINS SERVER  ------------------------------------
resource "oci_load_balancer_listener" "jenkins-server" {
  load_balancer_id         = "${oci_load_balancer_load_balancer.controlplane.id}"
  name                     = "jenkins-server-${var.name}-${var.env}"
  port                     = "8080"
  protocol                 = "TCP"
  default_backend_set_name = "${oci_load_balancer_backend_set.jenkins-server.name}"

  connection_configuration {
    idle_timeout_in_seconds = "60"
  }
}

resource "oci_load_balancer_backend_set" "jenkins-server" {
  health_checker {
    protocol          = "TCP"
    interval_ms       = "5000"
    port              = "31400"
    timeout_in_millis = "2000"
  }

  load_balancer_id = "${oci_load_balancer_load_balancer.controlplane.id}"
  name             = "jenkins-server-${var.name}-${var.env}"
  policy           = "LEAST_CONNECTIONS"
}

resource "oci_load_balancer_backend" "jenkins-server" {
  count            = "${var.infra-machine-count}"
  backendset_name  = "${oci_load_balancer_backend_set.jenkins-server.name}"
  ip_address       = "${element(oci_core_instance.infra.*.private_ip, count.index)}"
  load_balancer_id = "${oci_load_balancer_load_balancer.controlplane.id}"
  port             = "31400"

  lifecycle {
    ignore_changes = ["ip_address"]
  }
}

## ------------------------------------     LISTENER PER KUBERNETES DASHBOARD  ------------------------------------
resource "oci_load_balancer_listener" "kubernetes-dashboard" {
  load_balancer_id         = "${oci_load_balancer_load_balancer.controlplane.id}"
  name                     = "dashboard-${var.name}-${var.env}"
  port                     = "9090"
  protocol                 = "TCP"
  default_backend_set_name = "${oci_load_balancer_backend_set.kubernetes-dashboard.name}"

  connection_configuration {
    idle_timeout_in_seconds = "60"
  }
}

resource "oci_load_balancer_backend_set" "kubernetes-dashboard" {
  health_checker {
    protocol          = "TCP"
    interval_ms       = "5000"
    port              = "31038"
    timeout_in_millis = "2000"
  }

  load_balancer_id = "${oci_load_balancer_load_balancer.controlplane.id}"
  name             = "dashboard-${var.name}-${var.env}"
  policy           = "LEAST_CONNECTIONS"
}

resource "oci_load_balancer_backend" "kubernetes-dashboard" {
  count            = "${var.infra-machine-count}"
  backendset_name  = "${oci_load_balancer_backend_set.kubernetes-dashboard.name}"
  ip_address       = "${element(oci_core_instance.infra.*.private_ip, count.index)}"
  load_balancer_id = "${oci_load_balancer_load_balancer.controlplane.id}"
  port             = "31038"

  lifecycle {
    ignore_changes = ["ip_address"]
  }
}
