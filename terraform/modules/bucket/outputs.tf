output "name" {
  description = "The name of the bucket."
  value       = google_storage_bucket.bucket.name
}

output "url" {
  description = "The URI of the bucket."
  value       = google_storage_bucket.bucket.url
}
