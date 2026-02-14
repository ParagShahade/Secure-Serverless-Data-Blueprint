# GCP Services Documentation & Justifications

The Yepoda Data Pipeline leverages a suite of Google Cloud services, selected for their scalability, security, and alignment with modern cloud-native practices.

| Service | Purpose | Justification |
| :--- | :--- | :--- |
| **Cloud Function (Gen 2)** | Webhook Receiver | Provides a highly scalable, serverless endpoint to receive external HTTP requests. Built on GCF Gen 2 for seamless integration. |
| **Cloud Functions (Gen 2)** | Order Processor | Event-driven processing triggered natively by Pub/Sub. Ideal for short-lived, stateless transformations like PII hashing. |
| **Pub/Sub** | Message Broker | Decouples the ingestion layer from the processing layer, providing high availability and durability for incoming order data. |
| **Cloud Storage** | Object Storage | Used for both the landing zone (raw data) and the long-term archive (processed data). Offers excellent cost-efficiency and lifecycle management. |
| **BigQuery** | Data Warehouse | Scalable serverless analytics. Allows the business to query anonymized datasets at petabyte scale with SQL. |
| **Secret Manager** | Credential Storage | Securely manages sensitive values like the PII salt, ensuring they are never hardcoded in the application layer. |
| **Cloud KMS** | Encryption Management | Centrally manages encryption keys, giving the customer control over data access and visibility (CMEK). |
| **VPC & VPC Connector** | Private Networking | Ensures secure, private communication between serverless components and other internal resources. |
| **Cloud Identity (IAM)** | Access Control | Provides granular, identity-based security using service accounts and roles based on the principle of least privilege. |
