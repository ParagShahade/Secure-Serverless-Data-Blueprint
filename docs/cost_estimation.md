# Cost Estimation

The following is an estimated monthly cost for running the Yepoda Data Pipeline at a moderate scale (e.g., 10,000 orders per month).

| Service | Component | Estimated Monthly Cost (USD) |
| :--- | :--- | :--- |
| **Cloud Run/Functions** | Webhook + Processor | $0.00 (within Free Tier) |
| **Pub/Sub** | Messaging | $0.00 (within Free Tier) |
| **Cloud Storage** | ~100MB Raw + Processed | $0.05 |
| **BigQuery** | Storage + Analysis | $0.10 |
| **Cloud KMS** | 1 Key + Operations | $1.06 |
| **Secret Manager** | 1 Secret + Versions | $0.06 |
| **Networking** | VPC Connector | $5.00 (Standard fee) |
| **Logging/Monitoring** | Audit Logs | $0.10 |
| **Total** | | **~$6.37 / month** |

**Note**: Most of these services have generous free tiers. The primary fixed costs are the VPC Connector and Cloud KMS keys.
