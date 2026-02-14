import os
import json
import hashlib
import datetime
import base64
from google.cloud import storage
from google.cloud import bigquery

# Initialize clients
storage_client = None
bq_client = None

# Environment Variables
PROJECT_ID = os.environ.get("PROJECT_ID") or os.environ.get("GCP_PROJECT") or os.environ.get("GOOGLE_CLOUD_PROJECT")
RAW_BUCKET = os.environ.get("RAW_BUCKET")
PROCESSED_BUCKET = os.environ.get("PROCESSED_BUCKET")
BQ_DATASET = os.environ.get("BQ_DATASET")
BQ_TABLE = os.environ.get("BQ_TABLE")
PII_SALT = os.environ.get("PII_SALT", "default_salt")

print(f"Initializing Processor with PROJECT_ID: {PROJECT_ID}")

def hash_pii(value):
    """Hashes a PII value using SHA-256 and a salt."""
    if not value:
        return None
    salt = PII_SALT
    return hashlib.sha256((str(value) + salt).encode('utf-8')).hexdigest()

def process_order_pubsub(event, context):
    """
    Pub/Sub/HTTP Cloud Function.
    Handles both direct Pub/Sub Trigger (CloudEvent) and Pub/Sub Push (HTTP).
    """
    global storage_client, bq_client
    
    try:
        # Initialize clients lazily
        if storage_client is None:
            storage_client = storage.Client()
        if bq_client is None:
            bq_client = bigquery.Client()
            
        # 1. Extract Data
        data_encoded = None
        
        if hasattr(event, 'get_json'):
            # Incoming HTTP Request (Pub/Sub Push)
            request_json = event.get_json(silent=True)
            if request_json and 'message' in request_json:
                data_encoded = request_json['message'].get('data')
        elif hasattr(event, 'data'):
            # CloudEvent (GCF Event Trigger)
            pubsub_message = event.data.get('message', {})
            data_encoded = pubsub_message.get('data')
        elif isinstance(event, dict):
            # Fallback for dict-like event
            data_encoded = event.get('data')

        if data_encoded:
            data = base64.b64decode(data_encoded).decode('utf-8')
            request_json = json.loads(data)
        else:
            print("No data in message/request")
            return "No data", 204

        order_id = request_json.get('order_id', 'unknown')
        print(f"Processing order: {order_id}")

        # 1. Store Raw Data to GCS
        dt = datetime.datetime.now()
        blob_path = f"{dt.year}/{dt.month:02d}/{dt.day:02d}/{order_id}.json"
        
        if RAW_BUCKET:
            raw_bucket = storage_client.bucket(RAW_BUCKET)
            raw_blob = raw_bucket.blob(blob_path)
            raw_blob.upload_from_string(
                json.dumps(request_json), 
                content_type='application/json'
            )
            print(f"Stored raw data to gs://{RAW_BUCKET}/{blob_path}")

        # 2. Anonymize PII
        customer = request_json.get('customer', {})
        
        anonymized_record = {
            "order_id": order_id,
            "timestamp": request_json.get('timestamp'),
            "customer_hash": hash_pii(customer.get('email')),
            "customer_name_hash": hash_pii(customer.get('name')),
            "customer_address_hash": hash_pii(customer.get('address')),
            "items": request_json.get('items', []),
            "total_amount": request_json.get('total'),
            "currency": request_json.get('currency'),
            "processing_timestamp": datetime.datetime.utcnow().isoformat()
        }

        # 3. Store Processed Data to GCS
        if PROCESSED_BUCKET:
            processed_bucket = storage_client.bucket(PROCESSED_BUCKET)
            processed_blob = processed_bucket.blob(blob_path)
            processed_blob.upload_from_string(
                json.dumps(anonymized_record),
                content_type='application/json'
            )
            print(f"Stored processed data to gs://{PROCESSED_BUCKET}/{blob_path}")

        # 4. Insert into BigQuery
        if BQ_DATASET and BQ_TABLE:
            # Need to ensure BQ schema matches items array handling if strictly typed, 
            # but standard SQL insert handles JSON well if table is set up for it or auto-detect.
            # Assuming table exists.
            table_ref = f"{bq_client.project}.{BQ_DATASET}.{BQ_TABLE}"
            errors = bq_client.insert_rows_json(table_ref, [anonymized_record])
            if errors:
                print(f"BigQuery Insert Errors: {errors}")
                # Raising exception to trigger retry/DLQ
                raise RuntimeError(f"BigQuery Insert Errors: {errors}")
            print("Inserted into BigQuery successfully")
            
        return "OK", 200

    except Exception as e:
        print(f"Exception in process_order_pubsub: {e}")
        # Re-raise to trigger Pub/Sub retry mechanism
        raise e
