#! /bin/bash

ODH_NAMESPACE=trustyai-e2e
MM_NAMESPACE=trustyai-e2e-modelmesh

oc project $MM_NAMESPACE 2>&1 1>/dev/null
INFER_ROUTE_ALPHA=$(oc get route demo-loan-nn-alpha-onnx --template={{.spec.host}}{{.spec.path}})
INFER_ROUTE_BETA=$(oc get route demo-loan-nn-beta-onnx --template={{.spec.host}}{{.spec.path}})

LOOP_IDX=0
NFILES=$(ls resources/data_json/$1/*.json | wc -l | xargs)
THRESHOLD="${2:-$NFILES}"
BATCH_SIZE=500
PAUSE_TIME=0.005

oc project $ODH_NAMESPACE 2>&1 1>/dev/null
TRUSTY_POD=$(oc get pods -o name | grep trustyai)

check_for_reception () {
  while true
  do
    THRESH=$(( $1 * 975 / 1000 ))
    N_OBS=$(oc exec $TRUSTY_POD  -c trustyai-service -- bash -c "cat /inputs/demo-loan-nn-$2-onnx-metadata.json"  | jq .observations)
    echo -ne "\rMaking sure TrustyAI $2 dataset contains at least $THRESH points, has $N_OBS";
    if (( $N_OBS > $THRESH )); then
      break
    else
      sleep 1
    fi
  done
  echo " [done]"
}

# Init first dataset counter
if [[ -z $(oc exec $TRUSTY_POD -c trustyai-service -- bash -c "ls /inputs/ | grep demo-loan-nn-alpha") ]]; then
  START_OBS_ALPHA=0
else
  START_OBS_ALPHA=$(oc exec $TRUSTY_POD -c trustyai-service -- bash -c "cat /inputs/demo-loan-nn-alpha-onnx-metadata.json"  | jq .observations)
fi
echo "$START_OBS_ALPHA datapoints already in ALPHA dataset"

# Init second dataset counter
if [[ -z $(oc exec $TRUSTY_POD  -c trustyai-service -- bash -c "ls /inputs/ | grep demo-loan-nn-beta") ]]; then
  START_OBS_BETA=0
else
  START_OBS_BETA=$(oc exec $TRUSTY_POD -c trustyai-service -- bash -c "cat /inputs/demo-loan-nn-beta-onnx-metadata.json"  | jq .observations)
fi
echo "$START_OBS_BETA datapoints already in BETA dataset"


for data in $(ls resources/data_json/$1/*.json)
do
  if [ $(($LOOP_IDX % $BATCH_SIZE)) -eq 0 ] && [ $LOOP_IDX -gt 0 ]; then
    echo
    check_for_reception $(( $LOOP_IDX + $START_OBS_ALPHA )) "alpha"
    check_for_reception $(( $LOOP_IDX + $START_OBS_BETA )) "beta"
  fi

  echo -ne "\rSent datapoint $(( $LOOP_IDX + 1 )) of $THRESHOLD"
  curl -k https://$INFER_ROUTE_ALPHA/infer -d @$data > /dev/null 2>&1  &
  curl -k https://$INFER_ROUTE_BETA/infer -d @$data > /dev/null 2>&1  &

  sleep $PAUSE_TIME

  if [[ "$LOOP_IDX" -ge $(( $THRESHOLD - 1 )) ]]; then
    echo -e "\nAll datapoints sent"
    break
  fi

  let "LOOP_IDX++"
done

check_for_reception $(( $LOOP_IDX + $START_OBS_ALPHA + 1)) "alpha"
check_for_reception $(( $LOOP_IDX + $START_OBS_BETA + 1)) "beta"