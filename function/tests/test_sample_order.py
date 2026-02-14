import unittest
import json
import base64
from unittest.mock import Mock, patch
import sys
import os

# Add parent directory to path to import processor
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from processor import process_order_pubsub

class TestSampleOrder(unittest.TestCase):
    """
    Integration-style unit test that uses the actual sample_order.json 
    as defined in the case study requirements.
    """

    def setUp(self):
        # Path to the sample_order.json in the function directory
        self.json_path = os.path.join(
            os.path.dirname(os.path.dirname(os.path.abspath(__file__))), 
            "sample_order.json"
        )
        
        with open(self.json_path, 'r') as f:
            self.sample_data = json.load(f)

    @patch('processor.RAW_BUCKET', 'test-raw-bucket')
    @patch('processor.PROCESSED_BUCKET', 'test-processed-bucket')
    @patch('processor.BQ_DATASET', 'test-dataset')
    @patch('processor.BQ_TABLE', 'test-table')
    @patch('processor.storage_client')
    @patch('processor.bq_client')
    def test_process_sample_order(self, mock_bq, mock_storage, *args):
        """
        Verifies that the processor correctly handles the standard sample data structure.
        """
        # 1. Mock the incoming Pub/Sub message
        mock_request = Mock()
        mock_request.get_json.return_value = {
            'message': {
                'data': base64.b64encode(json.dumps(self.sample_data).encode()).decode()
            }
        }
        
        # 2. Mock GCP clients
        mock_storage.bucket.return_value.blob.return_value.upload_from_string = Mock()
        mock_bq.insert_rows_json.return_value = []
        
        # 3. Execute processing
        process_order_pubsub(mock_request, None)
        
        # 4. Assertions
        # Verify GCS Storage: Should be called twice (Raw and Processed)
        self.assertEqual(mock_storage.bucket.call_count, 2)
        
        # Verify BigQuery: Should be called once to insert the anonymized record
        self.assertTrue(mock_bq.insert_rows_json.called)
        
        # Verify call data
        args, kwargs = mock_bq.insert_rows_json.call_args
        anonymized_record = args[1][0]
        
        self.assertEqual(anonymized_record["order_id"], "ORD-2024-001")
        self.assertEqual(anonymized_record["total_amount"], 59.98)
        
        # Verify PII is NOT present in the record (hashes only)
        self.assertNotIn("customer@example.com", str(anonymized_record))
        self.assertNotIn("Jane Doe", str(anonymized_record))
        self.assertTrue(anonymized_record["customer_hash"])

if __name__ == '__main__':
    unittest.main()
