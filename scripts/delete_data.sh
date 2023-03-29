#! /bin/bash

ODH_NAMESPACE=trustyai-e2e

oc project $ODH_NAMESPACE 2>&1 1>/dev/null

oc exec $(oc get pods -o name | grep trustyai) -c trustyai-service -- bash -c "rm /inputs/demo-loan-rfc-*"