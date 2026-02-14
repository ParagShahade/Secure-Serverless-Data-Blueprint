import os
import json
import functions_framework
from google.cloud import pubsub_v1

# Initialize Pub/Sub publisher
publisher = pubsub_v1.PublisherClient()
PROJECT_ID = os.environ.get("PROJECT_ID") or os.environ.get("GCP_PROJECT") or os.environ.get("GOOGLE_CLOUD_PROJECT")
TOPIC_ID = os.environ.get("PUBSUB_TOPIC")

print(f"Initializing Webhook with PROJECT_ID: {PROJECT_ID}, TOPIC_ID: {TOPIC_ID}")

def get_topic_path(project_id, topic_id):
    if topic_id.startswith("projects/"):
        return topic_id
    return publisher.topic_path(project_id, topic_id)

def receive_order(request):
    """
    HTTP Cloud Function.
    Receives the order, validates it (basic), and publishes to Pub/Sub.
    """
    try:
        request_json = request.get_json(silent=True)
        
        if not request_json:
            return 'JSON payload required', 400

        # Basic Schema Validation (could be extended)
        required_fields = ['order_id', 'timestamp', 'customer', 'items', 'total']
        for field in required_fields:
            if field not in request_json:
                return f"Missing required field: {field}", 400

        # Publish to Pub/Sub
        if PROJECT_ID and TOPIC_ID:
            topic_path = get_topic_path(PROJECT_ID, TOPIC_ID)
            data_str = json.dumps(request_json)
            data = data_str.encode("utf-8")
            
            future = publisher.publish(topic_path, data)
            message_id = future.result()
            print(f"Published message {message_id} to {topic_path}")
            return f"Order received. ID: {message_id}", 200
        else:
            print("Pub/Sub configuration missing")
            return "Internal Server Error: Pub/Sub config missing", 500

    except Exception as e:
        print(f"Error receiving order: {e}")
        return f"Internal Server Error: {e}", 500
