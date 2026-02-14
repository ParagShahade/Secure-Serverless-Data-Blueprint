# Automated Testing

This directory contains unit and integration tests for the Cloud Functions.

## Test Structure

```
tests/
├── test_processor.py    # Unit tests for order processing logic
└── __init__.py          # Test package initialization
```

## Running Tests Locally

### Prerequisites
```bash
pip install -r requirements.txt
pip install pytest pytest-cov
```

### Run All Tests
```bash
cd function
python -m pytest tests/ -v
```

### Run with Coverage
```bash
python -m pytest tests/ --cov=. --cov-report=html
```

### Run Specific Test
```bash
python -m pytest tests/test_processor.py::TestPIIHashing::test_hash_pii_with_value -v
```

## Test Categories

### 1. **Unit Tests** (`test_processor.py`)
- **PII Hashing**: Validates pseudonymization logic
- **Order Processing**: Tests data transformation
- **Data Validation**: Ensures data quality checks
- **Error Handling**: Verifies graceful failure modes

### 2. **Integration Tests** (CI/CD Pipeline)
- End-to-end webhook → BigQuery flow
- GCS storage verification
- Pub/Sub message delivery

## CI/CD Integration

Tests run automatically in GitHub Actions:
- **On Pull Request**: All unit tests must pass
- **On Push to main**: Full integration test suite

See `.github/workflows/test.yaml` for configuration.

## Test Coverage Goals

- **Target**: 80%+ code coverage
- **Critical Paths**: 100% coverage for PII handling
- **Current Coverage**: Run `pytest --cov` to see report

## Writing New Tests

Follow this pattern:

```python
import unittest
from processor import your_function

class TestYourFeature(unittest.TestCase):
    def test_specific_behavior(self):
        result = your_function(input_data)
        self.assertEqual(result, expected_output)
```

## Mocking External Services

Use `unittest.mock` for GCP services:

```python
from unittest.mock import patch

@patch('processor.bq_client')
def test_with_mock_bigquery(self, mock_bq):
    mock_bq.insert_rows_json.return_value = []
    # Your test logic
```
