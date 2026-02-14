output "id" {
  value       = google_secret_manager_secret.secret.id
  description = "Secret ID (fully qualified)"
}

output "secret_id" {
  value       = google_secret_manager_secret.secret.secret_id
  description = "Secret ID (short)"
}

output "version" {
  value       = google_secret_manager_secret_version.version.name
  description = "Secret version"
}
