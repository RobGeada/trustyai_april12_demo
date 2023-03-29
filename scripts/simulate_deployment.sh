#! /bin/bash

ODH_NAMESPACE=trustyai-e2e
oc project $ODH_NAMESPACE 2>&1 1>/dev/null

LOOP_IDX=0
for batch in $(ls resources/data_json)
do
  if [ "$batch" = "batch_0" ]; then
    :
  else
    echo "===== Deployment Day $LOOP_IDX ====="
    scripts/send_data_batch.sh $batch

    for i in {1..5}
    do
      echo -ne "\rSleeping for rest of day...$((5 - $i))"
      sleep 1
    done
    echo
  fi

  let "LOOP_IDX++"
done