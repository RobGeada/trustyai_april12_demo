#! /bin/bash

ODH_NAMESPACE=trustyai-e2e
MM_NAMESPACE=trustyai-e2e-modelmesh
oc new-project $ODH_NAMESPACE
oc new-project $MM_NAMESPACE

oc project $ODH_NAMESPACE
TRUSTY_ROUTE=$(oc get route/trustyai --template={{.spec.host}})
REQUEST_ID="$(curl http://$TRUSTY_ROUTE/metrics/spd/requests | jq '.requests [0].id')"

curl -X DELETE --location http://$TRUSTY_ROUTE/metrics/spd/request \
    -H 'Content-Type: application/json' \
    -d "{
          \"requestId\": \"'"$REQUEST_ID"'\"
        }"

REQUEST_ID="$(curl http://$TRUSTY_ROUTE/metrics/dir/requests | jq '.requests [0].id')"

curl -X DELETE --location http://$TRUSTY_ROUTE/metrics/dir/request \
    -H 'Content-Type: application/json' \
    -d "{
          \"requestId\": \"'"$REQUEST_ID"'\"
        }"


for PROJECT in $ODH_NAMESPACE $MM_NAMESPACE
do
  oc project $PROJECT
  oc delete $(oc get kfdef -o name)
  oc delete $(oc get deployment -o name)
  oc delete $(oc get pod -o name)
  oc delete $(oc get cm -o name)
  oc delete $(oc get service -o name)
  oc delete $(oc get inferenceservices -o name)
  oc delete $(oc get servingruntime -o name)
  oc delete $(oc get pvc -o name)
  oc delete $(oc get secrets -o name)
done