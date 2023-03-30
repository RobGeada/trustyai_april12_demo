ODH_NAMESPACE=trustyai-e2e
MM_NAMESPACE=trustyai-e2e-modelmesh

oc project $ODH_NAMESPACE 2>&1 1>/dev/null
TRUSTY_ROUTE=$(oc get route/trustyai --template={{.spec.host}})

round() {
  printf "%.${2}f" "${1}"
}

for METRIC_NAME in "spd" "dir"
do
  METRIC_UPPERCASE=$(echo ${METRIC_NAME} | tr '[:lower:]' '[:upper:]')
  for MODEL in "alpha" "beta"
  do
    METRIC=$(curl -s -X POST --location "http://$TRUSTY_ROUTE/metrics/$METRIC_NAME" \
        -H "Content-Type: application/json" \
        -d "{
              \"modelId\": \"demo-loan-rfc-$MODEL\",
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
            }") 2>&1 1>/dev/null

    METRIC=$(echo $METRIC | sed -e 's/Group:input-3=1.0/Group:Gender=MALE/')
    METRIC=$(echo $METRIC | sed -e 's/Group:input-3=0.0/Group:Gender=NOT-MALE/')
    METRIC=$(echo $METRIC | sed -e 's/Outcome:output-0=0/Outcome:WILL-NOT-DEFAULT/')

    echo
    echo "== $METRIC_UPPERCASE Bias Report (Model $MODEL)=="
    echo "$METRIC_UPPERCASE Value: $(round $(echo $METRIC | jq .value) 6)"
    echo "Description:" $(echo $METRIC | jq .specificDefinition)
    echo "Unacceptably biased?" $(echo $METRIC | jq .thresholds.outsideBounds)

  done
done