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

DIR=$(curl -X POST --location "http://$TRUSTY_ROUTE/metrics/dir" \
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

SPD=$(echo $SPD | sed -e 's/Group:input-3=1.0/Group:Gender=MALE/')
SPD=$(echo $SPD | sed -e 's/Group:input-3=0.0/Group:Gender=NOT-MALE/')
SPD=$(echo $SPD | sed -e 's/Outcome:output-0=0/Outcome:WILL-NOT-DEFAULT/')

DIR=$(echo $DIR | sed -e 's/Group:input-3=1.0/Group:Gender=MALE/')
DIR=$(echo $DIR | sed -e 's/Group:input-3=0.0/Group:Gender=NOT-MALE/')
DIR=$(echo $DIR | sed -e 's/Outcome:output-0=0/Outcome:WILL-NOT-DEFAULT/')

echo
echo "== SPD BIAS REPORT =="
echo "SPD Value: $(echo $SPD | jq .value)"
echo "Description:" $(echo $SPD | jq .specificDefinition)
echo "Unacceptably biased?" $(echo $SPD | jq .thresholds.outsideBounds)

echo
echo "== DIR BIAS REPORT =="
echo "DIR Value: $(echo $DIR | jq .value)"
echo "Description:" $(echo $DIR | jq .specificDefinition)
echo "Unacceptably biased?" $(echo $DIR | jq .thresholds.outsideBounds)