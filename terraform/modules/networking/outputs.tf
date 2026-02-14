output "network_id" {
  value = google_compute_network.vpc_network.id
}

output "network_name" {
  value = google_compute_network.vpc_network.name
}

output "subnet_id" {
  value = google_compute_subnetwork.subnet.id
}

output "subnet_name" {
  value = google_compute_subnetwork.subnet.name
}

output "connector_id" {
  value = google_vpc_access_connector.connector.id
}
