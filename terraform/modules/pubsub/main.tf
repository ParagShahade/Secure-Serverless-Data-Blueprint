resource "google_pubsub_topic" "topic" {
  name         = var.topic_name
  project      = var.project_id
  kms_key_name = var.kms_key_name

  message_storage_policy {
    allowed_persistence_regions = [
      var.region,
    ]
  }

  labels = var.labels
}

resource "google_pubsub_topic" "dead_letter" {
  name         = var.dead_letter_topic_name
  project      = var.project_id
  kms_key_name = var.kms_key_name
}

resource "google_pubsub_subscription" "dead_letter_persistence" {
  name    = "${var.dead_letter_topic_name}-storage"
  topic   = google_pubsub_topic.dead_letter.id
  project = var.project_id

  message_retention_duration = "604800s" # 7 days
}

resource "google_pubsub_subscription" "subscription" {
  count   = var.create_subscription ? 1 : 0
  name    = var.subscription_name
  topic   = google_pubsub_topic.topic.id
  project = var.project_id

  ack_deadline_seconds = var.ack_deadline_seconds

  dead_letter_policy {
    dead_letter_topic     = google_pubsub_topic.dead_letter.id
    max_delivery_attempts = var.max_delivery_attempts
  }

  retry_policy {
    minimum_backoff = var.retry_minimum_backoff
    maximum_backoff = var.retry_maximum_backoff
  }

  dynamic "push_config" {
    for_each = var.push_endpoint != null ? [1] : []
    content {
      push_endpoint = var.push_endpoint

      dynamic "oidc_token" {
        for_each = var.oidc_service_account_email != null ? [1] : []
        content {
          service_account_email = var.oidc_service_account_email
        }
      }
    }
  }
}
