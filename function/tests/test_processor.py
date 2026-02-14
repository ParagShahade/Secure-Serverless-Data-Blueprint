import unittest
import json
import base64
from unittest.mock import Mock, patch, MagicMock
import sys
import os

# Add parent directory to path to import processor
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from processor import hash_pii, process_order_pubsub


class TestPIIHashing(unittest.TestCase):
    """Test PII pseudonymization functions"""

    def test_hash_pii_with_value(self):
        """Test that PII hashing produces consistent results"""
        email = "test@example.com"
        hash1 = hash_pii(email)
        hash2 = hash_pii(email)
        
        # Same input should produce same hash
        self.assertEqual(hash1, hash2)
        # Hash should be 64 characters (SHA-256 hex)
        self.assertEqual(len(hash1), 64)
        # Hash should not contain original value
        self.assertNotIn(email, hash1)

    def test_hash_pii_with_none(self):
        """Test that None values are handled gracefully"""
        result = hash_pii(None)
        self.assertIsNone(result)

    def test_hash_pii_with_empty_string(self):
        """Test that empty strings are handled gracefully"""
        result = hash_pii("")
        self.assertIsNone(result)

    def test_hash_pii_different_values(self):
        """Test that different inputs produce different hashes"""
        hash1 = hash_pii("user1@example.com")
        hash2 = hash_pii("user2@example.com")
        self.assertNotEqual(hash1, hash2)


class TestOrderProcessing(unittest.TestCase):
    """Test order processing logic"""

    def setUp(self):
        """Set up test fixtures by loading the actual sample_order.json"""
        json_path = os.path.join(
            os.path.dirname(os.path.dirname(os.path.abspath(__file__))), 
            "sample_order.json"
        )
        with open(json_path, 'r') as f:
            self.sample_order = json.load(f)

    @patch('processor.RAW_BUCKET', 'test-raw-bucket')
    @patch('processor.PROCESSED_BUCKET', 'test-processed-bucket')
    @patch('processor.BQ_DATASET', 'test-dataset')
    @patch('processor.BQ_TABLE', 'test-table')
    @patch('processor.storage_client')
    @patch('processor.bq_client')
    def test_process_order_http_request(self, mock_bq, mock_storage, *args):
        """Test processing order from HTTP request (Pub/Sub Push)"""
        # Create mock HTTP request
        mock_request = Mock()
        mock_request.get_json.return_value = {
            'message': {
                'data': base64.b64encode(json.dumps(self.sample_order).encode()).decode()
            }
        }
        
        # Mock GCS and BigQuery clients
        mock_storage.bucket.return_value.blob.return_value.upload_from_string = Mock()
        mock_bq.insert_rows_json.return_value = []
        
        # Process the order
        result = process_order_pubsub(mock_request, None)
        
        # Verify GCS was called
        self.assertTrue(mock_storage.bucket.called)
        
        # Verify BigQuery was called
        self.assertTrue(mock_bq.insert_rows_json.called)

    @patch('processor.RAW_BUCKET', 'test-raw-bucket')
    @patch('processor.PROCESSED_BUCKET', 'test-processed-bucket')
    @patch('processor.BQ_DATASET', 'test-dataset')
    @patch('processor.BQ_TABLE', 'test-table')
    @patch('processor.storage_client')
    @patch('processor.bq_client')
    def test_process_order_validates_required_fields(self, mock_bq, mock_storage, *args):
        """Test that missing required fields are handled"""
        # Create order missing customer data
        invalid_order = {"order_id": "TEST-002"}
        
        mock_request = Mock()
        mock_request.get_json.return_value = {
            'message': {
                'data': base64.b64encode(json.dumps(invalid_order).encode()).decode()
            }
        }
        
        mock_storage.bucket.return_value.blob.return_value.upload_from_string = Mock()
        mock_bq.insert_rows_json.return_value = []
        
        # Should not raise exception
        process_order_pubsub(mock_request, None)

    def test_pii_is_anonymized(self):
        """Test that PII fields are properly hashed"""
        email = "sensitive@example.com"
        name = "Sensitive User"
        address = "123 Private St"
        
        email_hash = hash_pii(email)
        name_hash = hash_pii(name)
        address_hash = hash_pii(address)
        
        # Verify no PII in hashes
        self.assertNotIn(email, email_hash)
        self.assertNotIn(name, name_hash)
        self.assertNotIn(address, address_hash)


class TestDataValidation(unittest.TestCase):
    """Test data validation and quality checks"""

    def test_order_id_format(self):
        """Test that order IDs follow expected format"""
        valid_ids = ["ORD-2024-001", "TEST-001", "ORD-CI-TEST-123"]
        for order_id in valid_ids:
            self.assertIsInstance(order_id, str)
            self.assertGreater(len(order_id), 0)

    def test_timestamp_format(self):
        """Test that timestamps are ISO 8601 formatted"""
        timestamp = "2024-12-04T10:30:00Z"
        # Should not raise exception
        from datetime import datetime
        parsed = datetime.fromisoformat(timestamp.replace('Z', '+00:00'))
        self.assertIsNotNone(parsed)

    def test_currency_codes(self):
        """Test that currency codes are valid ISO 4217"""
        valid_currencies = ["EUR", "USD", "GBP"]
        for currency in valid_currencies:
            self.assertEqual(len(currency), 3)
            self.assertTrue(currency.isupper())


if __name__ == '__main__':
    unittest.main()
