resource "google_compute_network" "vpc_network" {
  name                    = var.network_name
  auto_create_subnetworks = false
  project                 = var.project_id

  lifecycle {
    prevent_destroy = true
  }
}

resource "google_compute_subnetwork" "subnet" {
  name          = var.subnet_name
  ip_cidr_range = var.subnet_ip_cidr_range
  region        = var.region
  network       = google_compute_network.vpc_network.id
  project       = var.project_id

  private_ip_google_access = true

  log_config {
    aggregation_interval = "INTERVAL_10_MIN"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "google_vpc_access_connector" "connector" {
  name    = var.connector_name
  region  = var.region
  project = var.project_id
  subnet {
    name = google_compute_subnetwork.subnet.name
  }
  machine_type  = var.connector_machine_type
  min_instances = var.connector_min_instances
  max_instances = var.connector_max_instances
}

resource "google_compute_firewall" "internal" {
  name    = "${var.network_name}-allow-internal"
  network = google_compute_network.vpc_network.name
  project = var.project_id

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  source_ranges = [var.subnet_ip_cidr_range]
}
