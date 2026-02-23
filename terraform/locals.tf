locals {
  project_prefix = "data-pipeline"

  common_labels = {
    project     = "generic-data-pipeline"
    managed_by  = "terraform"
    environment = var.environment
    owner       = var.owner
  }
}
