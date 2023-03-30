#! /bin/bash

ODH_NAMESPACE=trustyai-e2e
MM_NAMESPACE=trustyai-e2e-modelmesh

oc project $ODH_NAMESPACE
TRUSTY_ROUTE=$(oc get route/trustyai --template={{.spec.host}})

for METRIC_NAME in "spd" "dir"
do
  for REQUEST in $(curl -s http://$TRUSTY_ROUTE/metrics/$METRIC_NAME/requests | jq -r '.requests [].id')
  do
    echo -n $REQUEST": "
    curl -X DELETE --location http://$TRUSTY_ROUTE/metrics/$METRIC_NAME/request \
        -H 'Content-Type: application/json' \
        -d "{
              \"requestId\": \"$REQUEST\"
            }"
    echo
  done
done