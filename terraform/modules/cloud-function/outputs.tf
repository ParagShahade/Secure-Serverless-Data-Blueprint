output "uri" {
  description = "The URI of the deployed service"
  value       = google_cloudfunctions2_function.function.service_config[0].uri
}

output "function_url" {
  description = "The URL of the deployed function"
  value       = google_cloudfunctions2_function.function.service_config[0].uri
}

output "name" {
  description = "The name of the function"
  value       = google_cloudfunctions2_function.function.name
}

output "service_account_email" {
  description = "The service account email used by the function"
  value       = module.service_account.email
}
