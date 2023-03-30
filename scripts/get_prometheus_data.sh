#! /bin/bash

ODH_NAMESPACE=trustyai-e2e
MM_NAMESPACE=trustyai-e2e-modelmesh


OPENSHIFT_OAUTH_ENDPOINT="https://$(oc get route -n openshift-authentication   oauth-openshift -o json | jq -r '.spec.host')"
oc adm policy add-role-to-user view -n ${ODH_NAMESPACE} --rolebinding-name "view-$(oc whoami)" $(oc whoami)
BEARER_TOKEN="$(curl -skiL -u $(oc whoami):$USER_PASS -H 'X-CSRF-Token: xxx' "$OPENSHIFT_OAUTH_ENDPOINT/oauth/authorize?response_type=token&client_id=openshift-challenging-client" | ggrep -oP 'access_token=\K[^&]*')"
MODEL_MONITORING_ROUTE=$(oc get route -n ${ODH_NAMESPACE} odh-model-monitoring --template={{.spec.host}})

curl -k --location -g --request GET "https://$MODEL_MONITORING_ROUTE/api/v1/query?query=trustyai_spd[10m]" -H 'Authorization: Bearer '$BEARER_TOKEN -i