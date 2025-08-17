provider "google" {
  project = "orange723"
}

terraform {
  required_version = ">= 0.12.0"

  backend "gcs" {
    bucket  = "terraform-example"
    prefix  = "gcp/loadbalancing/terraform.tfstate"
  }
}

data "google_compute_instance" "orange723" {
  name = "orange723"
  zone = "us-west1-a"
}

resource "google_compute_health_check" "check-orange723" {
  name = "check-orange723"

  timeout_sec        = 3
  check_interval_sec = 3

  tcp_health_check {
    port = "8080"
  }
}

resource "google_compute_instance_group" "group-orange723" {
  name        = "orange723"
  zone        = "us-west1-a"

  instances = [
    data.google_compute_instance.orange723.id,
   ]

  named_port {
    name = "http"
    port = 8080
  }
}

resource "google_compute_backend_service" "service-orange723" {
  name        = "service-orange723"

  load_balancing_scheme = "EXTERNAL_MANAGED"
  port_name   = "http"
  protocol    = "HTTP"

  health_checks = [
    google_compute_health_check.check-orange723.id,
  ]

  backend {
    group = google_compute_instance_group.group-orange723.self_link
  }
}

resource "google_compute_global_address" "address-orange723" {
  name = "address-orange723"
}

resource "google_compute_global_forwarding_rule" "rule-orange723" {
  name        = "rule-orange723"

  load_balancing_scheme = "EXTERNAL_MANAGED"
  ip_protocol = "TCP"
  port_range  = "443"
  target      = google_compute_target_https_proxy.httpsproxy-orange723.id
  ip_address  = google_compute_global_address.address-orange723.id
}

resource "google_compute_target_http_proxy" "httpproxy-orange723" {
  name    = "httpproxy-orange723"

  url_map = google_compute_url_map.urlmap-orange723.id
}

resource "google_compute_target_https_proxy" "httpsproxy-orange723" {
  name = "httpsproxy-orange723"

  ssl_certificates = [
    data.google_compute_ssl_certificate.orange723.id,
  ]

  url_map = google_compute_url_map.urlmap-orange723.id
}

resource "google_compute_url_map" "urlmap-orange723" {
  name = "urlmap-orange723"

  default_url_redirect {
    https_redirect = true
    strip_query    = false
  }

  host_rule {
    hosts = ["orange723.overwatch"]
    path_matcher = "orange723"
  }

  path_matcher {
    name = "orange723"
    default_service = google_compute_backend_service.service-orange723.id

    path_rule {
      paths = ["/*"]
      service = google_compute_backend_service.service-orange723.id
      route_action {
        cors_policy {
          allow_credentials = true
          allow_headers = ["*"]
          allow_origins = ["*"]
          allow_methods = ["GET", "POST", "OPTIONS"]
          disabled = false
        }
      }
    }
  }

}


data "google_compute_ssl_certificate" "orange723" {
  name = "orange723"
}