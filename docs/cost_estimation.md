
# Cost Estimation for running this infrastructure

**Project:** Data Pipeline
**Region:** `europe-west3` (Frankfurt)
**Estimated Monthly Cost:** **~€20.90**

## 1. Executive Summary

| Category | Service | Monthly Cost |
| :--- | :--- | :--- |
| **Network** | Serverless VPC Access | **€11.95** |
| **Analytics** | BigQuery | **€6.06** |
| **Compute** | Cloud Functions | **€2.33** |
| **Security** | KMS & Secret Manager | **€0.54** |
| **Storage** | GCS & Pub/Sub | **€0.02** |
| | **TOTAL** | **€20.90** |

---

## 2. Basis of Estimate (Assumptions)
All costs are calculated using the [Google Cloud Pricing Calculator](https://cloud.google.com/products/calculator) based on the following workload assumptions:

*   **Region:** Frankfurt (`europe-west3`)
*   **Order Volume:** 100,000 orders / month
*   **Payload Size:** 2 KB average per order
*   **Retention Policy:** Raw Data (7 Days), Processed Data (1 Year)
*   **Currency:** EUR (€)
*   **Free Tier:** **Excluded** (Conservative "Worst Case" Estimate)

---

## 3. Detailed Resource Breakdown

### A. Network Security (57% of Bill)
**Cost: €11.95 / month**
*   **Service:** `Serverless VPC Connector`
*   **Configuration:** `e2-micro` instance (2 min instances)
*   **Calculation:** 2 instances x 730 hours/month x €0.0083/hour

### B. Analytics (29% of Bill)
**Cost: €6.06 / month**
*   **Service:** `BigQuery`
*   **Configuration:** Standard Edition (European Multi-Region)
*   **Calculation:**
    *   **Analysis:** Estimated 1 TB queries / month (€6.00)
    *   **Storage:** ~2.4 GB accumulated / month (€0.06)

### C. Compute (11% of Bill)
**Cost: €2.33 / month**
*   **Service:** `Cloud Functions (Gen2)`
*   **Configuration:** 512MB RAM, 1 vCPU
*   **Calculation:**
    *   **Invocations:** 200,000 requests (€0.08)
    *   **Compute Time:** ~27.7 vCPU-hours (€2.13)
    *   **Memory:** ~13.8 GB-hours (€0.12)

### D. Security & Secrets (3% of Bill)
**Cost: €0.54 / month**
*   **Service:** `Secret Manager` & `Cloud KMS`
*   **Calculation:**
    *   **Secret Manager:** 1 Secret + 100k Access Ops (€0.36)
    *   **KMS:** 3 Key Versions (€0.18)

### E. Storage (<1% of Bill)
**Cost: €0.02 / month**
*   **Service:** `Cloud Storage` & `Pub/Sub`
*   **Calculation:** Minimal due to 7-day retention policy deleting old data.
