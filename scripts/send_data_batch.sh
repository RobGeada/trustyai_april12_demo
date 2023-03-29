#! /bin/bash

ODH_NAMESPACE=trustyai-e2e
MM_NAMESPACE=trustyai-e2e-modelmesh

oc project $MM_NAMESPACE 2>&1 1>/dev/null
INFER_ROUTE=$(oc get route demo-loan-rfc --template={{.spec.host}}{{.spec.path}})

LOOP_IDX=0
NFILES=$(ls resources/data_json/$1/*.json | wc -l | xargs)
THRESHOLD="${2:-$NFILES}"
BATCH_SIZE=500
PAUSE_TIME=0

oc project $ODH_NAMESPACE 2>&1 1>/dev/null

check_for_reception () {
  echo
  while true
  do
    N_OBS=$(oc exec $(oc get pods -o name | grep trustyai) -c trustyai-service -- bash -c "cat /inputs/demo-loan-rfc-metadata.json"  | jq .observations)
    echo -ne "\rMaking sure TrustyAI dataset contains $1 points, has $N_OBS"
    if [ $N_OBS == $1 ]; then
      break
    else
      echo -n "."
      sleep 1
    fi
  done
  echo " [done]"
}

if [[ -z $(oc exec $(oc get pods -o name | grep trustyai) -c trustyai-service -- bash -c "ls /inputs/ | grep demo-loan-rfc") ]]; then
  START_OBS=0
else
  START_OBS=$(oc exec $(oc get pods -o name | grep trustyai) -c trustyai-service -- bash -c "cat /inputs/demo-loan-rfc-metadata.json"  | jq .observations)
fi
echo "$START_OBS datapoints already in dataset"

for data in $(ls resources/data_json/$1/*.json)
do
  if [ $(($LOOP_IDX % $BATCH_SIZE)) -eq 0 ] && [ $LOOP_IDX -gt 0 ]; then
    check_for_reception $(( $LOOP_IDX + $START_OBS ))
  fi

  echo -ne "\rSent datapoint $(( $LOOP_IDX + 1 )) of $THRESHOLD"
  curl -k https://$INFER_ROUTE/infer -d @$data > /dev/null 2>&1 &
  sleep $PAUSE_TIME

  if [[ "$LOOP_IDX" -ge $(( $THRESHOLD - 1 )) ]]; then
    echo -e "\nAll datapoints sent"
    break
  fi

  let "LOOP_IDX++"
done

check_for_reception $(( $LOOP_IDX + $START_OBS + 1))