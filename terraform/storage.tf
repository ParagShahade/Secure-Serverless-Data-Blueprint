# The bucket where Terraform saves its own state (so multiple people can work together)
resource "google_storage_bucket" "tf_state" {
  # checkov:skip=CKV_GCP_62: Bucket access logging is out of scope for this pipeline
  name                        = "${var.project_id}-tfstate"
  location                    = var.region
  force_destroy               = false
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"

  versioning {
    enabled = true
  }

  lifecycle {
    prevent_destroy = true
  }

  depends_on = [google_project_service.apis]
}

# The bucket for incoming raw data
module "raw_data" {
  source = "./modules/bucket"

  name       = var.raw_bucket_name
  project_id = var.project_id
  location   = var.region

  force_destroy = true
  versioning    = true

  lifecycle_rules = [{
    action = {
      type = "Delete"
    }
    condition = {
      age = var.raw_bucket_age
    }
  }]
  encryption = {
    default_kms_key_name = google_kms_crypto_key.storage_key.id
  }
  labels = local.common_labels
}

# The bucket for cleaned and processed data
module "processed_data" {
  source = "./modules/bucket"

  name       = var.processed_bucket_name
  project_id = var.project_id
  location   = var.region

  force_destroy = true
  versioning    = true

  lifecycle_rules = [{
    action = {
      type = "Delete"
    }
    condition = {
      age = var.processed_bucket_age
    }
  }]
  encryption = {
    default_kms_key_name = google_kms_crypto_key.storage_key.id
  }
  labels = local.common_labels
}
