#!/bin/bash

if [[ -z "$BASHRC" ]]; then
  echo "You have need to set BASHRC as an env var"
  exit 1
fi

if [[ -z "$INGRESS_HOST" ]]; then
  echo "You have need to set INGRESS_HOST as an env var"
  exit 1
fi

sudo echo KEPTN_API_TOKEN=$(kubectl get secret keptn-api-token -n keptn -ojsonpath={.data.keptn-api-token} | base64 --decode) >> $BASHRC
sudo echo KEPTN_ENDPOINT=http://$INGRESS_HOST.nip.io/api >> $BASHRC
source $BASHRC

keptn auth --endpoint=$KEPTN_ENDPOINT --api-token=$KEPTN_API_TOKEN
kubectl -n keptn delete secret bridge-credentials --ignore-not-found=true
kubectl -n keptn delete pods --selector=app.kubernetes.io/name=bridge --wait

echo "The next recommended script to run is setup-project.sh"

