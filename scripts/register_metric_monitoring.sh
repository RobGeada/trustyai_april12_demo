ODH_NAMESPACE=trustyai-e2e
MM_NAMESPACE=trustyai-e2e-modelmesh
source scripts/const.sh

oc project $ODH_NAMESPACE >/dev/null 2>&1
TRUSTY_ROUTE=$(oc get route/trustyai --template={{.spec.host}})

for METRIC_NAME in "spd" "dir"
do
  METRIC_UPPERCASE=$(echo ${METRIC_NAME} | tr '[:lower:]' '[:upper:]')
  for MODEL in $MODEL_ALPHA $MODEL_BETA
  do
    curl -s --location http://$TRUSTY_ROUTE/metrics/$METRIC_NAME/request \
      --header 'Content-Type: application/json' \
      --data "{
                \"modelId\": \"$MODEL\",
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
    echo ": Registered real-time monitoring of $METRIC_UPPERCASE"
  done
done