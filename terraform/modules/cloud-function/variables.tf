variable "project_id" {
  description = "The ID of the project in which to provision resources."
  type        = string
}

variable "function_name" {
  description = "The name of the Cloud Function"
  type        = string
}

variable "description" {
  description = "Description of the function"
  type        = string
  default     = ""
}

variable "region" {
  description = "The region to deploy the function in"
  type        = string
}

variable "runtime" {
  description = "The runtime for the function"
  type        = string
}

variable "entry_point" {
  description = "The entry point in the source code"
  type        = string
}

variable "src_asset_filepath" {
  description = "Path to the zipped source code"
  type        = string
}

variable "src_asset_md5" {
  description = "MD5 hash of the source code zip"
  type        = string
}

variable "available_memory" {
  description = "Memory allocated for the function"
  type        = string
  default     = "256M"
}

variable "timeout_seconds" {
  description = "Timeout in seconds"
  type        = number
  default     = 60
}

variable "max_instance_count" {
  description = "Max number of instances"
  type        = number
  default     = 10
}

variable "vpc_connector" {
  description = "VPC Connector ID"
  type        = string
  default     = null
}

variable "environment_variables" {
  description = "Environment variables"
  type        = map(string)
  default     = {}
}

variable "secret_environment_variables" {
  description = "Secret environment variables"
  type = list(object({
    key        = string
    project_id = string
    secret     = string
    version    = string
  }))
  default = []
}

variable "event_trigger" {
  description = "Event trigger configuration"
  type = object({
    event_type   = string
    pubsub_topic = string
  })
  default = null
}

variable "invoker_members" {
  description = "Members to grant invoker role"
  type        = list(string)
  default     = []
}

variable "roles" {
  description = "Roles to grant to the function service account"
  type        = list(string)
  default     = []
}

variable "labels" {
  description = "Common labels"
  type        = map(string)
  default     = {}
}
