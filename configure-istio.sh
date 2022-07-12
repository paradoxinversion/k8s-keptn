#!/bin/bash

echo "Getting Istio Ingress info"
export INGRESS_HOST=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
export INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].port}')
export SECURE_INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="https")].port}')
export TCP_INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="tcp")].port}')

# Check that ingress host info is valid
if [ -z "$INGRESS_HOST" ] || [ "$INGRESS_HOST" = "Pending" ] ; then
 	echo "Could not determine the external IP address of istio-ingressgateway in namespace istio-system. Please make sure it is ready and has an external IP address:"
 	echo " - kubectl -n istio-system get svc istio-ingressgateway"
 	echo ""
 	echo "Please consult the istio docs for more information: https://istio.io/latest/docs/tasks/traffic-management/ingress/ingress-control/#determining-the-ingress-ip-and-ports"
	exit 1
fi

echo "External IP for istio-gateway is $INGRESS_HOST, Creating keptn configmaps"
cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    kubernetes.io/ingress.class: istio
  name: api-keptn-ingress
  namespace: keptn
spec:
  rules:
  - host: $INGRESS_HOST.nip.io
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: api-gateway-nginx
            port:
              number: 80
EOF

echo "Applying public gateway exposing deployed applications"
kubectl apply -f - <<EOF
---
apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: public-gateway
  namespace: istio-system
spec:
  selector:
    istio: ingressgateway
  servers:
  - port:
      name: http
      number: 80
      protocol: HTTP
    hosts:
    - '*'
EOF

echo "Sleeping for 10 seconds"
sleep 10s

#Create Keptn ingress config map
echo "Creating keptn ingress config map"
kubectl create configmap -n keptn ingress-config --from-literal=ingress_hostname_suffix=$(kubectl -n keptn get ingress api-keptn-ingress -ojsonpath='{.spec.rules[0].host}') --from-literal=ingress_port=80 --from-literal=ingress_protocol=http --from-literal=istio_gateway=public-gateway.istio-system -oyaml --dry-run=client | kubectl apply -f -

echo "Restarting helm service"
kubectl delete pod -n keptn -lapp.kubernetes.io/name=helm-service

echo "export INGRESS_HOST=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')" >> $BASHRC
echo "export INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].port}')" >> $BASHRC
echo "export SECURE_INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="https")].port}')" >> $BASHRC
echo "export TCP_INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="tcp")].port}')" >> $BASHRC

echo "The next script to run is authenticate-keptn.sh"

if [[ "$SETUP_PROCEED" == 1 ]]; then
  ./authenticate-keptn.sh
fi