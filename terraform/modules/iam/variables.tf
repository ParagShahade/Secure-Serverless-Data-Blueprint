variable "project_id" {
  description = "The ID of the project in which to provision resources."
  type        = string
}

variable "name" {
  description = "The name of the service account to create."
  type        = string
}

variable "display_name" {
  description = "The display name for the service account."
  type        = string
  default     = ""
}

variable "roles" {
  description = "Roles to grant to the service account."
  type        = list(string)
  default     = []
}
