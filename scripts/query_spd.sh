ODH_NAMESPACE=trustyai-e2e
MM_NAMESPACE=trustyai-e2e-modelmesh

oc project $ODH_NAMESPACE 2>&1 1>/dev/null
TRUSTY_ROUTE=$(oc get route/trustyai --template={{.spec.host}})

SPD=$(curl -X POST --location "http://$TRUSTY_ROUTE/metrics/spd" \
    -H "Content-Type: application/json" \
    -d "{
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
        }")

echo
echo "== SPD BIAS REPORT =="
echo "SPD Value: $(echo $SPD | jq .value)"
echo $(echo $SPD | jq .specificDefinition)
echo "Unacceptably biased?" $(echo $SPD | jq .thresholds.outsideBounds)