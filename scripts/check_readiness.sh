#! /bin/bash

source scripts/const.sh
ODH_NAMESPACE=trustyai-e2e
MM_NAMESPACE=trustyai-e2e-modelmesh


oc project $ODH_NAMESPACE
# wait for TrustyAI to spin up
echo -n "Waiting on trustyai pod to spin up "
while [[ -z "$(oc get pods | grep trustyai-service | grep 1/1)" ]]
do
  echo -n "."
  sleep 5
done
echo "[done]"


#oc label namespace $MM_NAMESPACE "modelmesh-enabled=true" --overwrite=true || echo "Failed to apply modelmesh-enabled label."
#oc apply -f resources/secret.yaml
#oc apply -f resources/ovms-1.x.yaml

#oc new-project $MM_NAMESPACE
oc project $MM_NAMESPACE
#oc apply -f resources/model0_onnx.yaml
#oc apply -f resources/model1_onnx.yaml

# wait to spin up ======================================================================================================
echo -n "Waiting on modelserving runtime pods to spin up "
while [[ -z "$(oc get pods | grep modelmesh-serving | grep 5/5)" ]]
do
  echo -n "."
  sleep 5
done
echo "[done]"

INFER_ROUTE_ALPHA=$(oc get route $MODEL_ALPHA --template={{.spec.host}}{{.spec.path}})

#while [[ -z "$(curl -k https://$INFER_ROUTE/infer -d @data.json | grep demo-loan-xgboost >/dev/null 2>&1)" ]]
echo -n "Wait for modelserving endpoint alpha to begin serving "
while [[ -z "$(curl -sk https://$INFER_ROUTE_ALPHA/infer -d @resources/dummy_data.json | grep $MODEL_ALPHA)" ]]
do
  echo -n "."
  sleep 5
done
echo "[done]"

INFER_ROUTE_BETA=$(oc get route $MODEL_BETA --template={{.spec.host}}{{.spec.path}})
#while [[ -z "$(curl -k https://$INFER_ROUTE/infer -d @data.json | grep demo-loan-xgboost >/dev/null 2>&1)" ]]
echo -n "Wait for modelserving endpoint beta to begin serving "
while [[ -z "$(curl -sk https://$INFER_ROUTE_BETA/infer -d @resources/dummy_data.json | grep $MODEL_BETA)" ]]
do
  echo -n "."
  sleep 5
done
echo "[done]"

scripts/delete_data.sh

