variable "project_id" {
  description = "The ID of the project."
  type        = string
}

variable "dataset_id" {
  description = "The ID of the dataset."
  type        = string
}

variable "friendly_name" {
  description = "The friendly name of the dataset."
  type        = string
  default     = null
}

variable "description" {
  description = "The description of the dataset."
  type        = string
  default     = null
}

variable "location" {
  description = "The location of the dataset."
  type        = string
}

variable "default_table_expiration_ms" {
  description = "The default table expiration in milliseconds."
  type        = number
  default     = null
}

variable "labels" {
  description = "The labels to apply to the dataset."
  type        = map(string)
  default     = {}
}

variable "tables" {
  description = "A map of tables to create. Key is table_id, value is object with schema."
  type = map(object({
    schema = string
  }))
  default = {}
}
