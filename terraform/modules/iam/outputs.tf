output "email" {
  description = "The email of the service account"
  value       = google_service_account.service_account.email
}

output "iam_email" {
  description = "The IAM member email of the service account"
  value       = "serviceAccount:${google_service_account.service_account.email}"
}

output "id" {
  description = "The ID of the service account"
  value       = google_service_account.service_account.name
}

output "name" {
  description = "The account ID of the service account"
  value       = google_service_account.service_account.account_id
}
