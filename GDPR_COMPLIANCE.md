
# GDPR Compliance Strategy & Security Posture

## 1. Introduction: Privacy by Design
The Yepoda Data Pipeline was built on a foundational philosophy of "Privacy by Design." My goal wasn't just to check regulatory boxes, but to architect a system where user privacy is the default state. The design centers on **Data Minimization**, **Purpose Limitation**, and ensuring **Integrity & Confidentiality** at every step. This document breaks down the specific technical decisions made to secure customer PII throughout its lifecycle.

## 2. PII Handling & Pseudonymization
One of the biggest challenges was protecting direct identifiers (Name, Email, Address) while still enabling valuable analytics. Rather than simple masking, I chose a robust **Pseudonymization** strategy.

*   **Why Salted Hashing?** Storing raw PII is too risky. Instead, identifiers are transformed using SHA-256 cryptographic hashing. This allows for deterministic analytics like tracking repeat customers without ever exposing their actual identity in the data warehouse.
*   **The "Salt" Decision:** Standard hashes are vulnerable to rainbow table attacks. To mitigate this, a high-entropy "Salt" is appended to every email before hashing. This salt is locked away in **Google Secret Manager**, ensuring that even if the database were leaked, the hashes would remain irreversible.
*   **Separation of Duties:** By isolating the salt from the analytics team, we create a cryptographic barrier. The data tells us *what* happened, without revealing *who* did it.

## 3. Data Minimization & Retention
Following GDPR Article 5(1)(c), the system is designed to "forget" data as soon as it's no longer needed.

*   **Raw Data (7-Day Limit):** Original JSON payloads containing PII are stored in an encrypted GCS bucket solely for disaster recovery. An automated Lifecycle Policy permanently deletes these files after **7 days**, drastically reducing the attack surface.
*   **Processed Data:** Anonymized records are retained for historical trend analysis. Since this data carries low re-identification risk, it is kept longer to support legitimate business insights.

## 4. Security Controls & Infrastructure
The architecture employs a "Defense in Depth" model, layering multiple security controls to protect the pipeline:

*   **Encryption (CMEK):** Relying solely on platform-managed keys felt insufficient for sensitive data. I implemented **Customer-Managed Encryption Keys (CMEK)** via Cloud KMS, ensuring we retain full control over data access.
*   **Network Isolation:** To prevent data exfiltration, the Cloud Functions operate within a private network via a **Serverless VPC Access Connector**. This ensures sensitive traffic never touches the public internet.
*   **Least Privilege (IAM):** Every component has a dedicated identity. For instance, the Webhook function can *write* to Pub/Sub but cannot *read* from it. This granular permission model minimizes the blast radius of any potential compromise.
*   **Secure CI/CD:** Deployment is automated using **Workload Identity Federation (WIF)**, eliminating the need for risky, long-lived service account keys.

## 5. Conclusion
By integrating cryptographic pseudonymization, strict retention schedules, and military-grade encryption, the pipeline demonstrates a mature approach to data privacy. It’s not just about compliance; it’s about building a resilient system that respects and protects user data by design.
