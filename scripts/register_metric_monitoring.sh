ODH_NAMESPACE=trustyai-e2e
MM_NAMESPACE=trustyai-e2e-modelmesh

oc project $ODH_NAMESPACE >/dev/null 2>&1
TRUSTY_ROUTE=$(oc get route/trustyai --template={{.spec.host}})

curl --location http://$TRUSTY_ROUTE/metrics/spd/request \
  --header 'Content-Type: application/json' \
  --data "{
            \"modelId\": \"demo-loan-rfc\",
            \"protectedAttribute\": \"input-3\",
            \"favorableOutcome\": {
              \"type\": \"INT32\",
              \"value\": 0
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
echo ": Registered real-time monitoring of SPD"

curl --location http://$TRUSTY_ROUTE/metrics/dir/request \
  --header 'Content-Type: application/json' \
  --data "{
            \"modelId\": \"demo-loan-rfc\",
            \"protectedAttribute\": \"input-3\",
            \"favorableOutcome\": {
              \"type\": \"INT32\",
              \"value\": 0
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
echo ": Registered real-time monitoring of DIR"