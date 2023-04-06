1. Login to the cluster
2. Install ODH operator

Run all of the following from the main directory:

# Available Scripts
## Install ODH + TrustyAI
`scripts/install.sh`

## Deploy Two ONNX Models
`scripts/deploy_models.sh`

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


# Suggested Script Order
```bash
scripts/install.sh
scripts/deploy_models.sh
scripts/send_data_batch training_data
scripts/query_fairness_metrics.sh
scripts/register_metric_monitoring.sh
scripts/simulate_deployment.sh

scripts/clean.sh
```
