//Vars
variable "project" {
  default = "proven-sum-150906"
}
variable "region" {
  default = "europe-west1"
}
variable "region_zone" {
  default = "europe-west1-b"
}
variable "count_instances" {
  default = "2"
}

// Configure the Google Cloud provider
provider "google" {
  credentials = "${file("account.json")}"
  project     = "${var.project}"
  region      = "${var.region}"
}

// Health Check
resource "google_compute_http_health_check" "default" {
  name               = "test-health-check"
  request_path       = "/"
  check_interval_sec = 1
  timeout_sec        = 1
}

resource "google_compute_global_address" "default" {
  name = "static-address"
}

resource "google_compute_instance_template" "apps" {
  name = "apps-template"
  machine_type = "f1-micro"

  network_interface {
    network = "default"
    access_config {
      # Ephemeral
    }
  }

  disk {
    source_image = "${var.project}/template-nginx-salt"
    auto_delete  = true
    boot         = true
  }
}

resource "google_compute_instance_group_manager" "apps" {
  name               = "apps"
  instance_template  = "${google_compute_instance_template.apps.self_link}"
  base_instance_name = "www"
  zone               = "${var.region_zone}"
  target_size        = "${var.count_instances}"
}

resource "google_compute_backend_service" "apps" {
  name        = "apps-service"
  description = "Applications pool"
  port_name   = "http"
  protocol    = "HTTP"
  timeout_sec = 10
  //enable_cdn  = false

  backend {
    group = "${google_compute_instance_group_manager.apps.instance_group}"
  }

  health_checks = ["${google_compute_http_health_check.default.self_link}"]
}

resource "google_compute_ssl_certificate" "default" {
  name        = "ssl-certificates"
  description = "SSL Certificates"
  private_key = "${file("ssl_cert/example.key")}"
  certificate = "${file("ssl_cert/example.crt")}"
}

resource "google_compute_target_http_proxy" "default" {
  name        = "apps-http-lb"
  description = "Application HTTP Load Balancer"
  url_map     = "${google_compute_url_map.default.self_link}"
}

resource "google_compute_target_https_proxy" "default" {
  name        = "apps-https-lb"
  description = "Application HTTPS Load Balancer"
  url_map     = "${google_compute_url_map.default.self_link}"
  ssl_certificates = ["${google_compute_ssl_certificate.default.self_link}"]
}

resource "google_compute_url_map" "default" {
  name        = "http-load-balancer"
  description = "HTTP Load Balancer"

  default_service = "${google_compute_backend_service.apps.self_link}"
}

resource "google_compute_global_forwarding_rule" "https" {
  name       = "frontend-https-lb"
  target     = "${google_compute_target_https_proxy.default.self_link}"
  port_range = "443"
  ip_address = "${google_compute_global_address.default.address}"
}

resource "google_compute_global_forwarding_rule" "http" {
  name       = "frontend-http-lb"
  target     = "${google_compute_target_http_proxy.default.self_link}"
  port_range = "80"
  ip_address = "${google_compute_global_address.default.address}"
}

// Firewall
resource "google_compute_firewall" "default-allow-http" {
  name    = "default-allow-http"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_ranges = ["0.0.0.0/0"]
}

output "pool_public_ip_https" {
  value = "${google_compute_global_forwarding_rule.https.ip_address}"
}
output "pool_public_ip_http" {
  value = "${google_compute_global_forwarding_rule.http.ip_address}"
}
