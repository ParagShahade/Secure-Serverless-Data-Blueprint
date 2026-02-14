output "topic_id" {
  value = google_pubsub_topic.topic.id
}

output "topic_name" {
  value = google_pubsub_topic.topic.name
}

output "subscription_id" {
  value = try(google_pubsub_subscription.subscription[0].id, "")
}


output "dead_letter_topic_id" {
  value = google_pubsub_topic.dead_letter.id
}

output "dead_letter_topic_name" {
  value = google_pubsub_topic.dead_letter.name
}
