#! /bin/bash

ODH_NAMESPACE=trustyai-e2e
MM_NAMESPACE=trustyai-e2e-modelmesh
oc new-project $ODH_NAMESPACE
oc new-project $MM_NAMESPACE

scripts/delete_all_requests.sh

for PROJECT in $ODH_NAMESPACE $MM_NAMESPACE
do
  oc project $PROJECT
  oc delete $(oc get kfdef -o name)
  oc delete $(oc get deployment -o name)
  oc delete $(oc get pod -o name)
  oc delete $(oc get cm -o name)
  oc delete $(oc get service -o name)
  oc delete $(oc get inferenceservices -o name)
  oc delete $(oc get servingruntime -o name)
  oc delete $(oc get pvc -o name)
  oc delete $(oc get secrets -o name)
done

oc delete project $MM_NAMESPACE