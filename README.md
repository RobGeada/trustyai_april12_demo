1. Login to the cluster
2. Install ODH operator

Run all of the following from the main directory:

# Available Scripts
## Install ODH 
`scripts/install.sh`

## Validate TrustyAI + Models are Spun Up
`scripts/check_readiness.sh`

## Data Scripts

#### Send Training Data
`scripts/send_data_batch training_data`

#### Simulate 11 Days of "Real" Data
`scripts/simulate_deployment.sh`

#### Delete All Data:
`scripts/delete_data.sh`

## Metrics
#### Single Instantaneous Metric Query
`scripts/query_fairness_metrics.sh`

#### Register Scheduled Metric Requests
`scripts/register_metric_monitoring.sh`

#### Delete all metric requests:
`scripts/delete_all_requests.sh`

## Clean up
`scripts/clean.sh`


# Demo Script Order
```bash
scripts/install.sh
[Deploy the TrustyAI Kfdef via the Openshift UI]
[Deploy the two models via ODH dashboard into trustyai-e2e-modelmesh project]
scripts/check_readiness.sh
scripts/send_data_batch training_data
scripts/register_metric_monitoring.sh
scripts/simulate_deployment.sh

scripts/clean.sh
```
