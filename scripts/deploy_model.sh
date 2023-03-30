#! /bin/bash

ODH_NAMESPACE=trustyai-e2e
MM_NAMESPACE=trustyai-e2e-modelmesh

oc label namespace $MM_NAMESPACE "modelmesh-enabled=true" --overwrite=true || echo "Failed to apply modelmesh-enabled label."
oc project $MM_NAMESPACE

oc apply -f resources/secret.yaml
oc apply -f resources/odh-mlserver-0.x.yaml

oc new-project $MM_NAMESPACE
oc project $MM_NAMESPACE
oc apply -f resources/model.yaml

# wait to spin up ======================================================================================================
while [[ -z "$(oc get pods | grep modelmesh-serving | grep 5/5)" ]]
do
  echo "Waiting on modelserving runtime pods to spin up"
  sleep 5
done

INFER_ROUTE=$(oc get route demo-loan-rfc --template={{.spec.host}}{{.spec.path}})
#while [[ -z "$(curl -k https://$INFER_ROUTE/infer -d @data.json | grep demo-loan-xgboost >/dev/null 2>&1)" ]]
while [[ -z "$(curl -k https://$INFER_ROUTE/infer -d @resources/dummy_data.json | grep demo-loan-rfc)" ]]
do
  echo "Wait for modelserving endpoint to begin serving..."
  sleep 5
done

scripts/delete_data.sh

