# Create the namespace and 
helm repo add argo https://argoproj.github.io/argo-helm
# helm repo add argo https://argoproj.github.io/argo-helm --set 'server.extraArgs=[--insecure]'
sudo curl -sSL -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
chmod +x /usr/local/bin/argocd


helm upgrade --install argo-cd argo/argo-cd -n argocd --create-namespace --set "server.extraArgs={--insecure}" --set "server.ingress.enabled=true"
cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    kubernetes.io/ingress.class: istio
  name: argocd-ingress
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
    secretName: argo-secret
EOF
cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: argocd-grpc-ingress
  namespace: argocd
  annotations:
    kubernetes.io/ingress.class: istio
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
    secretName: argo-secret
EOF

kubectl -n default get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d