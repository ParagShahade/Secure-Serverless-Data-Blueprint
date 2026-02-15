resource "google_bigquery_dataset" "dataset" {
  dataset_id                  = var.dataset_id
  friendly_name               = var.friendly_name
  description                 = var.description
  location                    = var.location
  default_table_expiration_ms = var.default_table_expiration_ms
  project                     = var.project_id
  labels                      = var.labels

  dynamic "default_encryption_configuration" {
    for_each = var.kms_key_name != null ? [1] : []
    content {
      kms_key_name = var.kms_key_name
    }
  }
}

resource "google_bigquery_table" "tables" {
  for_each = var.tables
  dataset_id          = google_bigquery_dataset.dataset.dataset_id
  table_id            = each.key
  project             = var.project_id
  schema              = each.value.schema
  deletion_protection = var.deletion_protection

  dynamic "encryption_configuration" {
    for_each = var.kms_key_name != null ? [1] : []
    content {
      kms_key_name = var.kms_key_name
    }
  }
}
