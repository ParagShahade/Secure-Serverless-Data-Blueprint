# Helper to get our project details
data "google_project" "project" {
  project_id = var.project_id
}

# Create a random ID for our encryption key ring (to keep it unique)
resource "random_id" "kms_suffix" {
  byte_length = 4
}

# The main key ring where we store our encryption keys
resource "google_kms_key_ring" "key_ring" {
  name     = "${local.project_prefix}-key-ring-${random_id.kms_suffix.hex}"
  location = var.region
  project  = var.project_id
}

# Encryption key for securing our files in GCS
resource "google_kms_crypto_key" "storage_key" {
  name            = "storage-key"
  key_ring        = google_kms_key_ring.key_ring.id
  rotation_period = "7776000s" # 90 days

  lifecycle {
    prevent_destroy = true
  }
}

# Encryption key for securing our messages in Pub/Sub
resource "google_kms_crypto_key" "pubsub_key" {
  name            = "pubsub-key"
  key_ring        = google_kms_key_ring.key_ring.id
  rotation_period = "7776000s" # 90 days

  lifecycle {
    prevent_destroy = true
  }
}

