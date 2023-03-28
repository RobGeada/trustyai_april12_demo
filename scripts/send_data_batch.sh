#! /bin/bash

ODH_NAMESPACE=trustyai-e2e
MM_NAMESPACE=trustyai-e2e-modelmesh

oc project $MM_NAMESPACE
INFER_ROUTE=$(oc get route demo-loan-rfc --template={{.spec.host}}{{.spec.path}})

LOOP_IDX=0
NFILES=$(ls resources/data_json/$1/*.json | wc -l | xargs)
THRESHOLD="${2:-$NFILES}"

for data in $(ls resources/data_json/$1/*.json)
do
  echo -ne "\rSent datapoint $LOOP_IDX of $THRESHOLD"
  curl -k https://$INFER_ROUTE/infer -d @$data >/dev/null 2>&1

  if [ $(($LOOP_IDX % 500)) -eq 0 ] && [ $LOOP_IDX -gt 0 ]; then
    sleep 1
  fi

  if [[ ! "$LOOP_IDX" -lt "$THRESHOLD" ]]; then
    echo -e "\nAll datapoints sent"
    break
  fi

  let "LOOP_IDX++"
done

oc project $ODH_NAMESPACE
echo "Waiting for all requests to be received..."
LAST_LOG=$(oc logs $(oc get pods -o name | grep trustyai-service) -c trustyai-service | tail -n 1)
while true
do
  CURR_LOG=$(oc logs $(oc get pods -o name | grep trustyai-service) -c trustyai-service | tail -n 1)
  if [ "$CURR_LOG" == "$LAST_LOG" ]; then
    break
  else
    LAST_LOG=$CURR_LOG
    sleep .5
  fi
done