resource "google_bigquery_dataset" "dataset" {
  dataset_id                  = var.dataset_id
  friendly_name               = var.friendly_name
  description                 = var.description
  location                    = var.location
  default_table_expiration_ms = var.default_table_expiration_ms
  project                     = var.project_id
  labels                      = var.labels
}

resource "google_bigquery_table" "tables" {
  for_each = var.tables

  dataset_id          = google_bigquery_dataset.dataset.dataset_id
  table_id            = each.key
  project             = var.project_id
  schema              = each.value.schema
  deletion_protection = false
}
