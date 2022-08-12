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
  tls:
  - hosts:
    - argocd.$INGRESS_HOST.nip.io
    secretName: argo-cert
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

EOF

export ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo)
echo "Your argocd password is $ARGOCD_PASSWORD"
echo "export ARGOCD_PASSWORD=$ARGOCD_PASSWORD" >> $RC_FILE
