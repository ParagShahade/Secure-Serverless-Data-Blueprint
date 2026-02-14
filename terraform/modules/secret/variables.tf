variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "id" {
  description = "The secret ID"
  type        = string
}

variable "secret_data" {
  description = "The secret data"
  type        = string
  sensitive   = true
}

variable "accessors" {
  description = "List of IAM members to grant access to"
  type        = list(string)
  default     = []
}
