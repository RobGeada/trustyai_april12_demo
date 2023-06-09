#! /bin/bash

# init =================================================================================================================
ODH_NAMESPACE=trustyai-e2e
MM_NAMESPACE=trustyai-e2e-modelmesh
oc new-project $ODH_NAMESPACE
#oc new-project $MM_NAMESPACE

oc project $ODH_NAMESPACE

# deploy a minimal ODH install  ========================================================================================
oc apply -f resources/odh-minimal.yaml

# deploy TrustyAI  =====================================================================================================
#oc apply -f resources/trustyai.yaml

oc patch CustomResourceDefinition/odhdashboardconfigs.opendatahub.io --type='json' -p='[{"op": "add", "path": "/spec/versions/0/schema/openAPIV3Schema/properties/spec/properties/dashboardConfig/properties/modelMetricsNamespace", "value":{"type":string}}]'
oc patch OdhDashboardConfig/odh-dashboard-config -p '{"spec":{"dashboardConfig":{"modelMetricsNamespace": "trustyai-e2e"}}}' --type='merge'


#
#ODH_NAMESPACE=trustyai-e2e
#MM_NAMESPACE=trustyai-e2e-modelmesh
#oc new-project $ODH_NAMESPACE
#oc new-project $MM_NAMESPACE
#
#oc project $ODH_NAMESPACE
#
## deploy a minimal ODH install  ========================================================================================
#oc apply -f resources/rhods-minimal.yaml
#
## deploy TrustyAI  =====================================================================================================
#oc apply -f resources/trustyai.yaml
#
## wait for TrustyAI to spin up
#while [[ -z "$(oc get pods | grep trustyai-service | grep 1/1)" ]]
#do
#  echo "Waiting on trustyai pod to spin up"
#  sleep 5
#done

### deploy ModelMesh ====================================================================================================
#oc apply -f model.yaml
#
## wait to spin up ======================================================================================================
#while [[ -z "$(oc get pods | grep modelmesh-serving | grep 5/5)" ]]
#do
#  echo "Waiting on modelserving runtime pods to spin up"
#  sleep 5
#done
#
#oc project $MM_NAMESPACE
#INFER_ROUTE=$(oc get route demo-loan-xgboost --template={{.spec.host}}{{.spec.path}})
#while [[ -z "$(curl -k https://$INFER_ROUTE/infer -d @data.json | grep demo-loan-xgboost)" ]]
#do
#  echo "Wait for modelserving endpoint to begin serving..."
#  sleep 5
#done
#
## get + send data to model route  ======================================================================================
#for i in {1..5};
#do
#  curl -k https://$INFER_ROUTE/infer -d @data.json
#done
#
#echo
#echo "Waiting for requests to appear in TrustyAI pod logs..."
#sleep 10
#
## see if payloads are in logs  =========================================================================================
#oc project $ODH_NAMESPACE
#if [[ -z "$(oc logs $(oc get pods -o name | grep trustyai-service) | grep "Received partial input payload")" ]];
#then
#  echo "ERROR: No payload communication between ModelMesh + TrustyAI"
#  exit
#fi
#
## grab + run data generator  ===========================================================================================
#[ -d "logger" ] && rm -Rf logger
#cp -r ../explainability-service/demo/logger logger
#TRUSTY_ROUTE=$(oc get route/trustyai-service-route --template={{.spec.host}})
#echo "TrustyAI Route at $TRUSTY_ROUTE"
#cd logger
#
#sed "s/sleep(random.randint(1, 3))/sleep(0.01)/" partial.py > partial-fast-gen.py
#SERVICE_ENDPOINT=http://$TRUSTY_ROUTE/consumer/kserve/v2 nohup python3 partial-fast-gen.py &
#GENERATOR_PID=$!
#echo "Data Generator (PID $GENERATOR_PID) is running; waiting 60 seconds to generate some data..."
#echo
#cd ..
#sleep 60
#
## see if example model payloads are in logs ============================================================================
#oc project $ODH_NAMESPACE
#if [[ -z "$(oc logs $(oc get pods -o name | grep trustyai-service) | grep "Received partial input payload")" ]];
#then
#  echo "ERROR: No payload communication between Data Generator + TrustyAI"
#  exit
#fi
#
#
## setup a metric  chedule===============================================================================================
#curl --location http://$TRUSTY_ROUTE/metrics/spd/request \
#  --header 'Content-Type: application/json' \
#  --data '{
#      "modelId": "example-model-1",
#      "protectedAttribute": "input-2",
#      "favorableOutcome": {
#          "type": "DOUBLE",
#          "value": 1.0
#      },
#      "outcomeName": "output-0",
#      "privilegedAttribute": {
#          "type": "DOUBLE",
#          "value": 0.0
#      },
#      "unprivilegedAttribute": {
#          "type": "DOUBLE",
#          "value": 1.0
#      }
#  }'
#
