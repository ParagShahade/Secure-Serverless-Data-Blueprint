# GDPR Compliance Report: Yepoda Data Pipeline

## Executive Summary
The Yepoda Data Pipeline is a purpose-built infrastructure designed to handle sensitive e-commerce order data with a "Security-First" and "Privacy by Design" mindset. In compliance with General Data Protection Regulation (GDPR) standards, this report details the technical and organizational measures implemented to protect customer Personnel Identifiable Information (PII).

## Data Pseudonymization & Hashing
The core technical control for GDPR compliance is the **pseudonymization** of sensitive data fields. 
- **Cryptographic Hashing**: PII fields (Email, Name, Address) are never stored in their raw form in the analytics layer. Instead, they are transformed using the **SHA-256** hashing algorithm.
- **Salted Security**: To prevent dictionary or rainbow table attacks, a high-entropy "salt" is appended to the data prior to hashing. This salt is managed via **Google Secret Manager**, ensuring that only authorized services can access the cryptographic material.
- **Deterministic Tokenization**: This approach allows for deterministic analytics (identifying repeat customers) without ever exposing the individual's actual identity to the database users or analytics dashboards.

## Storage Isolation & Data Minimization
Data is strictly partitioned based on its sensitivity and lifecycle requirements:
- **Landing Zone (Raw Data)**: Original payloads containing PII are stored in an isolated, encrypted Google Cloud Storage (GCS) bucket. Access is restricted to the Processing Function only.
- **Analytics Zone (Processed Data)**: Only the anonymized records are propagated to the final BigQuery dataset and the Processed GCS bucket. 
- **Principle of Minimization**: The pipeline discards unnecessary PII metadata (like full payment details) at the ingestion point, ensuring we only store what is strictly necessary for legitimate business operations.

## Retention & Automatic Deletion Policies
Automated Lifecycle Policies ensure data is not kept longer than necessary:
- **Ephemeral Storage**: Raw PII is purged after **7 days**, minimizing the impact of potential security incidents.
- **Processed Retention**: Anonymized records are retained for **1 year** for trend analysis, then automatically deleted.

## Google Cloud Security Best Practices
The implementation adheres to the following GCP security pillars:
- **CMEK (Customer-Managed Encryption Keys)**: All data at rest in GCS, Pub/Sub, and BigQuery is protected by keys managed in **Cloud KMS**. We implemented 90-day rotation periods for these keys to enhance security posture.
- **IAM Least Privilege**: Each component (Webhook, Processor, Pub/Sub) operates under a dedicated Identity and Access Management (IAM) Service Account with only the specific roles required for its function (e.g., `storage.objectCreator`).
- **Private Networking**: Data transit between the Cloud Functions and other GCP services occurs over a **Private VPC network** via Serverless VPC Connectors. This ensures that PII data never traverses the public internet once it enters the Google network.
- **Auditability**: **Cloud Audit Logs** are enabled project-wide, providing an immutable trail of every access attempt to sensitive data. This ensures full transparency for compliance audits.

## Conclusion
By integrating robust pseudonymization, granular access controls, and automated data lifecycle management, the Yepoda Data Pipeline provides a state-of-the-art framework for secure e-commerce data processing that meets the highest standards of data privacy and GDPR compliance.
