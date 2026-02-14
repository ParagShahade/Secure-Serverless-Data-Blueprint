locals {
  project_prefix = "yepoda"

  common_labels = {
    project     = "yepoda-data-pipeline"
    managed_by  = "terraform"
    environment = var.environment
    owner       = var.owner
  }
}
