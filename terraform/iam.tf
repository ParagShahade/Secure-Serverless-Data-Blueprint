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

# Give the service account permission to write to our data buckets
resource "google_storage_bucket_iam_member" "raw_bucket_writer" {
  bucket = module.raw_data.name
  role   = "roles/storage.objectCreator"
  member = local.pipeline_sa_iam_email
}

# Let the service account write to the processed data bucket
resource "google_storage_bucket_iam_member" "processed_bucket_writer" {
  bucket = module.processed_data.name
  role   = "roles/storage.objectCreator"
  member = local.pipeline_sa_iam_email
}

# Let the service account edit data in BigQuery
resource "google_bigquery_dataset_access" "bq_writer" {
  dataset_id    = module.bigquery.dataset_id
  role          = "roles/bigquery.dataEditor"
  user_by_email = local.pipeline_sa_email
}

# Allow the service account to write logs
resource "google_project_iam_member" "logging_writer" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = local.pipeline_sa_iam_email
}

# Allow the service account to publish messages to Pub/Sub
resource "google_pubsub_topic_iam_member" "publisher" {
  project = var.project_id
  topic   = module.pubsub.topic_name
  role    = "roles/pubsub.publisher"
  member  = local.pipeline_sa_iam_email
}

# Allow the service account to trigger our functions (Cloud Run)
resource "google_cloud_run_service_iam_member" "pubsub_invoker" {
  project  = var.project_id
  location = var.region
  service  = module.order_processor.name
  role     = "roles/run.invoker"
  member   = local.pipeline_sa_iam_email
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

# Make sure the service account can manage the state bucket
resource "google_storage_bucket_iam_member" "state_bucket_admin" {
  bucket = "${var.project_id}-tfstate"
  role   = "roles/storage.objectAdmin"
  member = local.pipeline_sa_iam_email
}
