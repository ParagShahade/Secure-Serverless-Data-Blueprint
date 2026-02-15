terraform {
  backend "gcs" {
    bucket = "alpine-ship-487308-k0-tfstate"
    prefix = "terraform/state"
  }

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

provider "google-beta" {
  project = var.project_id
  region  = var.region
}

# Enable the Google Cloud APIs we need for this project
resource "google_project_service" "apis" {
  for_each = toset([
    "cloudresourcemanager.googleapis.com", # Required for IAM operations
    "iam.googleapis.com",                  # Required for service accounts and IAM
    "cloudkms.googleapis.com",             # Required for encryption keys
    "vpcaccess.googleapis.com",            # Required for VPC connector
    "compute.googleapis.com",              # Required for networking
    "pubsub.googleapis.com",               # Required for Pub/Sub topics
    "secretmanager.googleapis.com",        # Required for secrets
    "cloudfunctions.googleapis.com",       # Required for Cloud Functions
    "run.googleapis.com",                  # Required for Cloud Run (used by Cloud Functions Gen2)
    "artifactregistry.googleapis.com",     # Required for storing function artifacts
    "cloudbuild.googleapis.com",           # Required for building functions
    "bigquery.googleapis.com",             # Required for BigQuery datasets and tables
    "storage.googleapis.com",              # Required for Cloud Storage buckets
    "logging.googleapis.com",              # Required for Cloud Logging
    "monitoring.googleapis.com"            # Required for Cloud Monitoring alerts
  ])
  project = var.project_id
  service = each.key

  disable_on_destroy = false
}

# Set up the networking (VPC, Subnets, and Serverless Connector)
module "networking" {
  source = "./modules/networking"

  project_id = var.project_id
  region     = var.region

  network_name            = var.vpc_network_name
  subnet_name             = var.vpc_subnet_name
  subnet_ip_cidr_range    = var.vpc_subnet_cidr
  connector_name          = var.vpc_connector_name
  connector_machine_type  = var.vpc_connector_machine_type
  connector_min_instances = var.vpc_connector_min_instances
  connector_max_instances = var.vpc_connector_max_instances

  labels = local.common_labels

  depends_on = [google_project_service.apis]
}

# Configure Workload Identity so GitHub Actions can talk to Google Cloud securely
module "gh_wif" {
  source = "./modules/wif"

  project_id = var.project_id

  pool_display_name     = "GitHub Actions Pool"
  provider_display_name = "GitHub Actions Provider"

  attribute_condition = "assertion.repository == 'ParagShahade/yepoda-assignment'"
  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.actor"      = "assertion.actor"
    "attribute.repository" = "assertion.repository"
  }

  sa_mapping = {
    "pipeline-sa" = {
      sa_name   = module.pipeline_sa.id
      attribute = "attribute.repository/ParagShahade/yepoda-assignment"
    }
  }
}
