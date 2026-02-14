output "dataset_id" {
  description = "The ID of the dataset."
  value       = google_bigquery_dataset.dataset.dataset_id
}

output "table_ids" {
  description = "Map of table IDs."
  value       = { for t in google_bigquery_table.tables : t.table_id => t.table_id }
}
