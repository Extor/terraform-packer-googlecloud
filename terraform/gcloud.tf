//Vars
variable "project" {
  default = "proven-sum-150906"
}
variable "region" {
  default = "asia-east1-a"
}

// Configure the Google Cloud provider
provider "google" {
  credentials = "${file("account.json")}"
  project     = "${var.project}"
  region      = "${var.region}"
}

// Create first instance
resource "google_compute_instance" "first" {
  name         = "terratest1"
  machine_type = "n1-standard-1"
  zone         = "${var.region}"

  disk {
    image = "${var.project}/template-nginx-salt"
  }

  // Disk
  disk {
    type    = "local-ssd"
    scratch = "True"
  }

  // Network
  network_interface {
    network = "default"
    access_config {
      nat_ip = ""
    }
  }
}

// Create a second instance
resource "google_compute_instance" "second" {
  name         = "terratest2"
  machine_type = "n1-standard-1"
  zone         = "${var.region}"

  disk {
    image = "${var.project}/template-nginx-salt"
  }

  // Disk
  disk {
    type    = "local-ssd"
    scratch = "True"
  }

  // Network
  network_interface {
    network = "default"
    access_config {
      nat_ip = ""
    }
  }
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
