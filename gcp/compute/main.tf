provider "google" {
  project = "orange723"
}

terraform {
  required_version = ">= 0.12.0"

  backend "gcs" {
    bucket  = "terraform-example"
    prefix  = "gcp/compute/terraform.tfstate"
  }
}

data "google_compute_network" "default" {
  name = "default"
}

data "google_compute_subnetwork" "us-west1" {
  name   = "default"
  region = "us-west1"
}

data "google_compute_image" "ubuntu-2204" {
  name    = "ubuntu-2204-jammy-v20241218"
  project = "ubuntu-os-cloud"
}

resource "google_compute_firewall" "firewall-orange723" {
  name = "firewall-orange723"
  allow {
    ports    = ["22"]
    protocol = "tcp"
  }
  direction     = "INGRESS"
  network       = data.google_compute_network.default.name
  priority      = 1000
  source_ranges = ["0.0.0.0/0"]
  target_tags  = ["orange723"]
}

resource "google_compute_address" "address-orange723" {
  name = "address-orange723"
  region = "us-west1"
}

resource "google_compute_instance" "orange723" {
  name         = "orange723"
  machine_type = "e2-medium"
  zone         = "us-west1-a"
  tags         = ["terraform", "orange723"]
  labels       = {
    "tag"  = "orange723"
  }

  boot_disk {
    initialize_params {
      image = data.google_compute_image.ubuntu-2204.self_link
      type  = "pd-ssd"
      size  = 50
    }
  }

  allow_stopping_for_update = true
  deletion_protection = true
  enable_display      = true

  network_interface {
    network = data.google_compute_network.default.name

    access_config {
      nat_ip = google_compute_address.address-orange723.address
    }
  }

  metadata = {
    enable-osconfig         = "TRUE"
    enable-guest-attributes = "TRUE"
    ssh-keys                = <<-EOF
      orange723:ssh-ed25519 AAAA orange723
    EOF
  }

  service_account {
    email  = "orange723@developer.gserviceaccount.com"
    scopes = ["https://www.googleapis.com/auth/devstorage.write_only", "https://www.googleapis.com/auth/logging.write", "https://www.googleapis.com/auth/monitoring.write", "https://www.googleapis.com/auth/service.management.readonly", "https://www.googleapis.com/auth/servicecontrol", "https://www.googleapis.com/auth/trace.append"]
  }

  shielded_instance_config {
    enable_integrity_monitoring = true
    enable_secure_boot          = false
    enable_vtpm                 = true
  }

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
    preemptible         = false
    provisioning_model  = "STANDARD"
  }
}