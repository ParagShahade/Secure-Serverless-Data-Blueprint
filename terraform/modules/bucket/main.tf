resource "google_storage_bucket" "bucket" {
  # checkov:skip=CKV_GCP_62: Bucket access logging is out of scope for this pipeline
  name                        = var.name
  location                    = var.location
  project                     = var.project_id
  force_destroy               = var.force_destroy
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"

  versioning {
    enabled = var.versioning
  }

  dynamic "lifecycle_rule" {
    for_each = var.lifecycle_rules
    content {
      action {
        type = lifecycle_rule.value.action.type
      }
      condition {
        age = lookup(lifecycle_rule.value.condition, "age", null)
      }
    }
  }

  dynamic "encryption" {
    for_each = var.encryption != null ? [var.encryption] : []
    content {
      default_kms_key_name = encryption.value.default_kms_key_name
    }
  }

  labels = var.labels
}
