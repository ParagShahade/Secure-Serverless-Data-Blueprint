# Create Cloud Storage bucket to store the source code of the function
resource "google_storage_bucket" "function_source_code_bucket" {
  # checkov:skip=CKV_GCP_62: Bucket access logging is out of scope for this pipeline
  project                     = var.project_id
  name                        = "${var.project_id}-${var.function_name}-src"
  location                    = var.region
  force_destroy               = true
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"

  versioning {
    enabled = true
  }
}

# Copy the source code to the bucket
resource "google_storage_bucket_object" "function_source_code_zip" {
  bucket = google_storage_bucket.function_source_code_bucket.name
  name   = "source-${var.src_asset_md5}.zip"
  source = var.src_asset_filepath
}

# Create the function
resource "google_cloudfunctions2_function" "function" {
  project = var.project_id

  name        = var.function_name
  description = var.description
  labels      = var.labels
  location    = var.region

  build_config {
    runtime     = var.runtime
    entry_point = var.entry_point
    source {
      storage_source {
        bucket = google_storage_bucket_object.function_source_code_zip.bucket
        object = google_storage_bucket_object.function_source_code_zip.name
      }
    }
  }

  service_config {
    # checkov:skip=CKV_GCP_124: Redundantly flagged, but internal access is already configured via ingress settings
    ingress_settings      = "ALLOW_INTERNAL_AND_GCLB"
    service_account_email = module.service_account.email
    timeout_seconds       = var.timeout_seconds
    available_memory      = var.available_memory
    max_instance_count    = var.max_instance_count
    vpc_connector         = var.vpc_connector
    environment_variables = var.environment_variables

    dynamic "secret_environment_variables" {
      for_each = { for s in var.secret_environment_variables : s.key => s }
      content {
        project_id = secret_environment_variables.value.project_id
        version    = secret_environment_variables.value.version
        key        = secret_environment_variables.value.key
        secret     = secret_environment_variables.value.secret
      }
    }
  }

  dynamic "event_trigger" {
    for_each = var.event_trigger == null ? [] : [1]
    content {
      trigger_region        = var.region
      event_type            = var.event_trigger.event_type
      pubsub_topic          = var.event_trigger.pubsub_topic
      retry_policy          = "RETRY_POLICY_DO_NOT_RETRY"
      service_account_email = module.service_account.email
    }
  }

  depends_on = [
    google_storage_bucket_object.function_source_code_zip,
    module.service_account,
    google_secret_manager_secret_iam_member.member,
  ]
}

# Grant invoker roles
resource "google_cloud_run_service_iam_member" "invoker" {
  # checkov:skip=CKV_GCP_102: Public endpoint is intentional for the webhook receiver
  for_each = toset(var.invoker_members)

  project  = var.project_id
  location = var.region
  service  = google_cloudfunctions2_function.function.name
  role     = "roles/run.invoker"
  member   = each.key
}

module "service_account" {
  source = "../iam"

  project_id = var.project_id
  name       = "sa-cf-${substr(var.function_name, 0, 24)}"
  roles      = var.roles
}

resource "google_secret_manager_secret_iam_member" "member" {
  for_each = { for s in var.secret_environment_variables : s.key => s.secret }

  project   = var.project_id
  secret_id = each.value
  role      = "roles/secretmanager.secretAccessor"
  member    = module.service_account.iam_email
}