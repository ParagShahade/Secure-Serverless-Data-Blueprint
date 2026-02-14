variable "project_id" {
  description = "The ID of the project."
  type        = string
}

variable "region" {
  description = "The region for message storage."
  type        = string
}

variable "topic_name" {
  description = "The name of the main topic."
  type        = string
}

variable "dead_letter_topic_name" {
  description = "The name of the dead letter topic."
  type        = string
}

variable "subscription_name" {
  description = "The name of the subscription."
  type        = string
}

variable "create_subscription" {
  description = "Whether to create the main subscription"
  type        = bool
  default     = true
}

variable "kms_key_name" {
  description = "The KMS key name for encryption."
  type        = string
}

variable "ack_deadline_seconds" {
  description = "Ack deadline in seconds."
  type        = number
  default     = 10
}

variable "max_delivery_attempts" {
  description = "Max delivery attempts before moving to DLQ."
  type        = number
  default     = 5
}

variable "retry_minimum_backoff" {
  description = "Minimum backoff for retries."
  type        = string
  default     = "10s"
}

variable "retry_maximum_backoff" {
  description = "Maximum backoff for retries."
  type        = string
  default     = "600s"
}

variable "push_endpoint" {
  description = "The URL of the push target (optional)"
  type        = string
  default     = null
}

variable "oidc_service_account_email" {
  description = "The service account email for OIDC token (optional)"
  type        = string
  default     = null
}

variable "labels" {
  description = "A mapping of labels to assign to the topic."
  type        = map(string)
  default     = {}
}
