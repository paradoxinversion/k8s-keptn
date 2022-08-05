# Install CLI
ARGOCD_VERSION=v2.3.5
sudo curl -sSL -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/download/$ARGOCD_VERSION/argocd-linux-amd64
sudo chmod +x /usr/local/bin/argocd

# Install Argo
helm repo add argo https://argoproj.github.io/argo-helm
helm upgrade argocd argo/argo-cd --install --namespace argocd --create-namespace \
--set "server.extraArgs={--insecure}"

helm upgrade -f - argocd argo/argo-cd --install --namespace argocd --create-namespace << EOF
server:
  extraArgs:
  - --insecure
  ingress:
    enabled: true
    hosts:
    - argocd.$INGRESS_HOST.nip.io
    annotations:
      kubernetes.io/ingress.class: istio
EOF

# Create an ingress for the argocd server HTTP/HTTPS
# This will work for browser access, but not CLI access
cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    kubernetes.io/ingress.class: istio
  name: argocd-server
  namespace: argocd
spec:
  rules:
    - host: argocd.$INGRESS_HOST.nip.io
      http:
        paths:
        - path: /
          pathType: Prefix
          backend:
            service:
              name: argocd-server
              port:
                number: 80
    tls:
    - hosts:
      - argocd.$INGRESS_HOST.nip.io
      secretName: argo-cert
EOF


# Create a secure gateway
kubectl apply -f - <<EOF
apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: argocd-gateway
  namespace: istio-system
spec:
  selector:
    istio: ingressgateway
  servers:
  - hosts:
    - argocd.$INGRESS_HOST.nip.io
    port:
      number: 443
      name: https
      protocol: HTTPS
    tls:
      mode: SIMPLE
      credentialName: argo-cert
EOF


kubectl apply -f - <<EOF
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: argocd-server-vs
  namespace: argocd
spec:
  hosts:
  - argocd-server
  gateways:
  - argocd-gateway
  tls:
  - match:
    - port: 443
      sniHosts:
      - argocd-server
    route:
    - destination:
        host: argocd-server
        port:
          number: 443
EOF
