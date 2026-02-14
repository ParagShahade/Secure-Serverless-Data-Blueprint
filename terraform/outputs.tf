# The final URL of our webhook receiver
output "webhook_uri" {
  value = module.webhook_receiver.uri
}

# The names of our data buckets
output "raw_bucket" {
  value = module.raw_data.name
}

output "processed_bucket" {
  value = module.processed_data.name
}

output "bq_dataset" {
  value = module.bigquery.dataset_id
}

output "wif_pool_name" {
  value = module.gh_wif.pool_name
}

output "wif_provider_name" {
  value = module.gh_wif.provider_name
}

output "wif_service_account" {
  value = module.pipeline_sa.email
}
