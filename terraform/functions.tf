data "archive_file" "functions_src" {
  type        = "zip"
  source_dir  = var.src_path
  output_path = "${var.src_path}src.zip"
}

module "webhook_receiver" {
  source = "./modules/cloud-function"

  project_id    = var.project_id
  function_name = "yepoda-webhook-receiver"
  description   = "Receives orders and publishes to Pub/Sub"
  region        = var.region

  runtime     = var.function_runtime
  entry_point = "receive_order"

  src_asset_filepath = data.archive_file.functions_src.output_path
  src_asset_md5      = data.archive_file.functions_src.output_md5

  available_memory   = "256M"
  max_instance_count = 10
  vpc_connector      = module.networking.connector_id

  environment_variables = {
    PROJECT_ID   = var.project_id
    PUBSUB_TOPIC = module.pubsub.topic_id
  }

  invoker_members = ["allUsers"]
  roles           = ["roles/pubsub.publisher"]

  labels = local.common_labels
}

module "order_processor" {
  source = "./modules/cloud-function"

  project_id    = var.project_id
  function_name = "yepoda-order-processor"
  description   = "Processes and anonymizes order data"
  region        = var.region

  runtime     = var.function_runtime
  entry_point = "process_order_pubsub"

  src_asset_filepath = data.archive_file.functions_src.output_path
  src_asset_md5      = data.archive_file.functions_src.output_md5

  available_memory   = "512M"
  max_instance_count = 10
  vpc_connector      = module.networking.connector_id

  environment_variables = {
    PROJECT_ID       = var.project_id
    RAW_BUCKET       = module.raw_data.name
    PROCESSED_BUCKET = module.processed_data.name
    BQ_DATASET       = module.bigquery.dataset_id
    BQ_TABLE         = module.bigquery.table_ids[var.bq_table_name]
  }

  invoker_members = ["serviceAccount:sa-cf-yepoda-order-processor@${var.project_id}.iam.gserviceaccount.com"]

  secret_environment_variables = [
    {
      key        = "PII_SALT"
      project_id = var.project_id
      secret     = module.pii_salt.secret_id
      version    = "latest"
    }
  ]

  event_trigger = {
    event_type   = "google.cloud.pubsub.topic.v1.messagePublished"
    pubsub_topic = module.pubsub.topic_id
  }

  roles = [
    "roles/storage.objectAdmin",
    "roles/bigquery.dataEditor",
  ]

  labels = local.common_labels
}