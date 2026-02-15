# Create the main service account that runs our pipeline
module "pipeline_sa" {
  source       = "./modules/iam"
  project_id   = var.project_id
  name         = var.sa_account_id
  display_name = var.sa_display_name
}

# Helpers for readability
locals {
  pipeline_sa_email     = module.pipeline_sa.email
  pipeline_sa_iam_email = module.pipeline_sa.iam_email
}

# Give the service account permission to manage all project resources (scoper admin roles)
resource "google_project_iam_member" "pipeline_sa_admin_roles" {
  # checkov:skip=CKV_GCP_49: Pipeline SA requires service account management permissions to deploy infrastructure
  for_each = toset([
    "roles/storage.admin",
    "roles/bigquery.admin",
    "roles/pubsub.admin",
    "roles/cloudfunctions.admin",
    "roles/run.admin",
    "roles/artifactregistry.admin",
    "roles/cloudbuild.builds.editor",
    "roles/iam.serviceAccountAdmin",
    "roles/compute.networkAdmin",
    "roles/cloudkms.admin",
    "roles/secretmanager.admin",
    "roles/serviceusage.serviceUsageAdmin",
    "roles/monitoring.admin",
    "roles/logging.configWriter"
  ])

  project = var.project_id
  role    = each.key
  member  = local.pipeline_sa_iam_email
}

# Grant Pub/Sub Service Agent permission to publish to DLQ
resource "google_pubsub_topic_iam_member" "pubsub_agent_dlq_publisher" {
  project = var.project_id
  topic   = module.pubsub.dead_letter_topic_name
  role    = "roles/pubsub.publisher"
  member  = "serviceAccount:service-${data.google_project.project.number}@gcp-sa-pubsub.iam.gserviceaccount.com"
}

# Grant Pub/Sub Service Agent permission to subscribe to the source subscription (required for DLQ)
resource "google_pubsub_subscription_iam_member" "pubsub_agent_subscriber" {
  count        = module.pubsub.subscription_id != "" ? 1 : 0
  project      = var.project_id
  subscription = module.pubsub.subscription_id
  role         = "roles/pubsub.subscriber"
  member       = "serviceAccount:service-${data.google_project.project.number}@gcp-sa-pubsub.iam.gserviceaccount.com"
}

# Grant Pub/Sub Service Agent permission to create tokens (required for push triggers)
resource "google_service_account_iam_member" "pubsub_agent_token_creator" {
  service_account_id = module.pipeline_sa.id
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = "serviceAccount:service-${data.google_project.project.number}@gcp-sa-pubsub.iam.gserviceaccount.com"
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

# Grant BigQuery Service Agent permission to use the key
resource "google_kms_crypto_key_iam_member" "bq_key_binding" {
  crypto_key_id = google_kms_crypto_key.storage_key.id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:bq-${data.google_project.project.number}@bigquery-encryption.iam.gserviceaccount.com"
}

# Grant Cloud Function Service Accounts permission to use the key
resource "google_kms_crypto_key_iam_member" "webhook_key_binding" {
  crypto_key_id = google_kms_crypto_key.pubsub_key.id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:${module.webhook_receiver.service_account_email}"
}

resource "google_kms_crypto_key_iam_member" "processor_key_binding" {
  crypto_key_id = google_kms_crypto_key.storage_key.id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:${module.order_processor.service_account_email}"
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
