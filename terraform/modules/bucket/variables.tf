variable "name" {
  description = "The name of the bucket."
  type        = string
}

variable "project_id" {
  description = "The ID of the project."
  type        = string
}

variable "location" {
  description = "The location of the bucket."
  type        = string
}

variable "force_destroy" {
  description = "When deleting a bucket, this boolean option will delete all contained objects."
  type        = bool
}

variable "versioning" {
  description = "Enable versioning."
  type        = bool
}

variable "lifecycle_rules" {
  description = "List of lifecycle rules to configure."
  type = list(object({
    action = object({
      type = string
    })
    condition = object({
      age = number
    })
  }))
  default = []
}

variable "encryption" {
  description = "Encryption configuration"
  type = object({
    default_kms_key_name = string
  })
  default = null
}

variable "labels" {
  description = "A mapping of labels to assign to the bucket."
  type        = map(string)
  default     = {}
}
