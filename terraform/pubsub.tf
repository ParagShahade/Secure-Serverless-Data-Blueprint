module "pubsub" {
  source = "./modules/pubsub"

  project_id             = var.project_id
  region                 = var.region
  topic_name             = var.pubsub_topic_name
  dead_letter_topic_name = var.pubsub_dead_letter_topic_name
  subscription_name      = var.pubsub_subscription_name
  create_subscription    = false
  kms_key_name           = google_kms_crypto_key.pubsub_key.id

  labels = local.common_labels
}
