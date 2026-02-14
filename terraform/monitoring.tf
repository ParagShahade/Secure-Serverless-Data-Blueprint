resource "google_monitoring_alert_policy" "dlq_alert" {
  display_name = "DLQ Message Count High"
  project      = var.project_id
  combiner     = "OR"
  conditions {
    display_name = "DLQ Messages > 0"
    condition_threshold {
      filter     = "resource.type = \"pubsub_subscription\" AND resource.labels.subscription_id = \"${module.pubsub.dead_letter_topic_name}\" AND metric.type = \"pubsub.googleapis.com/subscription/num_undelivered_messages\""
      duration   = "300s"
      comparison = "COMPARISON_GT"
      aggregations {
        alignment_period   = "600s"
        per_series_aligner = "ALIGN_MEAN"
      }
      threshold_value = 0
    }
  }

  notification_channels = [] # Add notification channels if needed

  user_labels = local.common_labels
}
