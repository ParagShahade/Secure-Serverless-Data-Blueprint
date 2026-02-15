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

# Give Google Cloud permission to use our keys for storage and messages
data "google_storage_project_service_account" "storage_sa" {
  project = var.project_id
}

resource "google_kms_crypto_key_iam_member" "storage_key_binding" {
  crypto_key_id = google_kms_crypto_key.storage_key.id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:${data.google_storage_project_service_account.storage_sa.email_address}"
}

resource "google_kms_crypto_key_iam_member" "pubsub_key_binding" {
  crypto_key_id = google_kms_crypto_key.pubsub_key.id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:service-${data.google_project.project.number}@gcp-sa-pubsub.iam.gserviceaccount.com"
}

# Securely store the secret "salt" used for hashing customer IDs
module "pii_salt" {
  source = "./modules/secret"

  project_id  = var.project_id
  id          = var.pii_salt_secret_id
  secret_data = var.pii_salt_value

  accessors = [
    local.pipeline_sa_iam_email
  ]
}

# Turn on security logs so we can see who accessed what data
resource "google_project_iam_audit_config" "audit_log" {
  project = var.project_id
  service = "allServices"
  audit_log_config {
    log_type = "ADMIN_READ"
  }
  audit_log_config {
    log_type = "DATA_READ"
  }
  audit_log_config {
    log_type = "DATA_WRITE"
  }
}
