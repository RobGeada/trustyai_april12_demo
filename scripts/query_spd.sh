ODH_NAMESPACE=trustyai-e2e
MM_NAMESPACE=trustyai-e2e-modelmesh

oc project $ODH_NAMESPACE
TRUSTY_ROUTE=$(oc get route/trustyai-service-route --template={{.spec.host}})

curl -X POST --location "http://$TRUSTY_ROUTE/metrics/spd" \
    -H "Content-Type: application/json" \
    -d "{
          \"modelId\": \"demo-loan-rfc\",
          \"protectedAttribute\": \"input-3\",
          \"favorableOutcome\": {
            \"type\": \"INT64\",
            \"value\": 1
          },
          \"outcomeName\": \"output-0\",
          \"privilegedAttribute\": {
            \"type\": \"DOUBLE\",
            \"value\": 1.0
          },
          \"unprivilegedAttribute\": {
            \"type\": \"DOUBLE\",
            \"value\": 0.0
          }
        }"