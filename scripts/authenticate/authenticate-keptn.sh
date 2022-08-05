#!/bin/bash

if [[ -z "$INGRESS_HOST" ]]; then
  echo "You have need to set INGRESS_HOST as an env var"
  exit 1
fi

export KEPTN_API_TOKEN=$(kubectl get secret keptn-api-token -n keptn -ojsonpath={.data.keptn-api-token} | base64 --decode)
export KEPTN_ENDPOINT=http://$INGRESS_HOST.nip.io/api >> $BASHRC

keptn auth --endpoint=$KEPTN_ENDPOINT --api-token=$KEPTN_API_TOKEN
kubectl -n keptn delete secret bridge-credentials --ignore-not-found=true
kubectl -n keptn delete pods --selector=app.kubernetes.io/name=bridge --wait

echo "export KEPTN_API_TOKEN=$KEPTN_API_TOKEN" >> $BASHRC
echo "export KEPTN_ENDPOINT=$KEPTN_ENDPOINT" >> $BASHRC


echo "The next recommended script to run is ./install-prometheus.sh"

if [[ "$SETUP_PROCEED" == 1 ]]; then
  ./install-prometheus.sh
fi