module "bigquery" {
  source = "./modules/bigquery"

  project_id                  = var.project_id
  dataset_id                  = var.bq_dataset_id
  location                    = var.location
  friendly_name               = var.bq_dataset_friendly_name
  description                 = var.bq_dataset_description
  default_table_expiration_ms = var.bq_table_expiration_ms

  labels = merge(var.bq_labels, local.common_labels)

  tables = {
    (var.bq_table_name) = {
      schema = <<EOF
[
  {
    "name": "order_id",
    "type": "STRING",
    "mode": "REQUIRED"
  },
  {
    "name": "timestamp",
    "type": "TIMESTAMP",
    "mode": "REQUIRED"
  },
  {
    "name": "customer_hash",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "Pseudonymized hash of customer email"
  },
  {
    "name": "customer_name_hash",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "Pseudonymized hash of customer name"
  },
  {
    "name": "customer_address_hash",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "Pseudonymized hash of customer address"
  },
  {
    "name": "items",
    "type": "RECORD",
    "mode": "REPEATED",
    "fields": [
      {
        "name": "sku",
        "type": "STRING",
        "mode": "REQUIRED"
      },
      {
        "name": "quantity",
        "type": "INTEGER",
        "mode": "REQUIRED"
      },
      {
        "name": "price",
        "type": "FLOAT",
        "mode": "REQUIRED"
      }
    ]
  },
  {
    "name": "total_amount",
    "type": "FLOAT",
    "mode": "REQUIRED"
  },
  {
    "name": "currency",
    "type": "STRING",
    "mode": "REQUIRED"
  },
  {
    "name": "processing_timestamp",
    "type": "TIMESTAMP",
    "mode": "NULLABLE"
  }
]
EOF
    }
  }
}
