variable "project_id" {
  description = "The ID of the GCP project"
  type        = string
  default     = "YOUR_PROJECT_ID"
}

variable "region" {
  description = "The region to deploy resources to"
  type        = string
  default     = "europe-west3"
}

variable "location" {
  description = "region location for buckets and datasets"
  type        = string
  default     = "europe-west3"
}

variable "environment" {
  description = "Execution environment (prod, dev, staging)"
  type        = string
  default     = "prod"
}

variable "owner" {
  description = "Resource owner"
  type        = string
  default     = "data-engineering"
}


# Storage Variables
variable "raw_bucket_name" {
  description = "Name of the GCS bucket for raw data"
  type        = string
  default     = "raw-orders-bucket"
}

variable "raw_bucket_age" {
  description = "Lifecycle age (days) for raw bucket"
  type        = number
  default     = 7
}

variable "processed_bucket_name" {
  description = "Name of the GCS bucket for processed data"
  type        = string
  default     = "processed-orders-bucket"
}

variable "processed_bucket_age" {
  description = "Lifecycle age (days) for processed bucket"
  type        = number
  default     = 365
}

# BigQuery Variables
variable "bq_dataset_id" {
  description = "BigQuery Dataset ID"
  type        = string
  default     = "order_analytics"
}

variable "bq_dataset_friendly_name" {
  description = "BigQuery Dataset Friendly Name"
  type        = string
  default     = "Order Analytics"
}

variable "bq_dataset_description" {
  description = "BigQuery Dataset Description"
  type        = string
  default     = "Dataset for anonymized order data"
}

variable "bq_table_expiration_ms" {
  description = "Default table expiration in ms"
  type        = number
  default     = 31536000000
}

variable "bq_labels" {
  description = "BigQuery Dataset Labels"
  type        = map(string)
  default     = {
    env        = "production"
    compliance = "gdpr"
  }
}

variable "bq_table_name" {
  description = "BigQuery Table Name"
  type        = string
  default     = "orders_anonymized"
}

# Cloud Function Variables
variable "src_path" {
  description = "Source code path of the functions"
  type        = string
  default     = "../function/"
}
variable "function_runtime" {
  description = "Cloud Function Runtime"
  type        = string
  default     = "python310"
}

# IAM Variables
variable "sa_account_id" {
  description = "Service Account ID"
  type        = string
  default     = "pipeline-sa"
}

variable "sa_display_name" {
  description = "Service Account Display Name"
  type        = string
  default     = "Data Pipeline Service Account"
}

# Secret Variables
variable "pii_salt_secret_id" {
  description = "Secret ID for PII Salt"
  type        = string
  default     = "pii-salt-secret"
}

variable "pii_salt_value" {
  description = "Value for PII Salt"
  type        = string
  sensitive   = true
}

# Networking Variables
variable "vpc_network_name" {
  description = "Name of the VPC network"
  type        = string
  default     = "main-vpc"
}

variable "vpc_subnet_name" {
  description = "Name of the VPC subnet"
  type        = string
  default     = "main-subnet"
}

variable "vpc_subnet_cidr" {
  description = "IP CIDR range for the VPC subnet"
  type        = string
  default     = "10.0.0.0/28"
}

variable "vpc_connector_name" {
  description = "Name of the VPC Access Connector"
  type        = string
  default     = "vpc-connector"
}

variable "vpc_connector_machine_type" {
  description = "Machine type for the VPC Connector"
  type        = string
  default     = "e2-micro"
}

variable "vpc_connector_min_instances" {
  description = "Minimum instances for the VPC Connector"
  type        = number
  default     = 2
}

variable "vpc_connector_max_instances" {
  description = "Maximum instances for the VPC Connector"
  type        = number
  default     = 3
}

# Pub/Sub Variables
variable "pubsub_ack_deadline_seconds" {
  description = "Ack deadline for Pub/Sub subscription"
  type        = number
  default     = 60
}

variable "pubsub_max_delivery_attempts" {
  description = "Max delivery attempts for Pub/Sub"
  type        = number
  default     = 5
}

variable "pubsub_topic_name" {
  description = "The name of the main Pub/Sub topic"
  type        = string
  default     = "orders-topic"
}

variable "pubsub_dead_letter_topic_name" {
  description = "The name of the Pub/Sub dead letter topic"
  type        = string
  default     = "orders-dlq-topic"
}

variable "pubsub_subscription_name" {
  description = "The name of the Pub/Sub subscription"
  type        = string
  default     = "order-processor-sub"
}

