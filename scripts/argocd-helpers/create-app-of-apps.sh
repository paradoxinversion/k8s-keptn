# Setup app of apps and sync
argocd app create applications \
    --dest-namespace argocd \
    --dest-server https://kubernetes.default.svc \
    --repo https://github.com/paradoxinversion/cna-helm-chart-repo.git \
    --path app-of-apps  
argocd app sync applications

# Setup apps within app of apps
# Make sure to create namespaces for each before syncing
kubectl create namespace containerized-node-app
kubectl label namespace containerized-node-app istio-injection=enabled --overwrite
argocd app sync containerized-node-app

kubectl apply -f - <<EOF
apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: argocd-app-gateway
  namespace: istio-system
spec:
  selector:
    istio: ingressgateway
  servers:
  - port:
      number: 80
      name: http
      protocol: HTTP
    hosts:
    - "containerized-node-app.$INGRESS_HOST.nip.io"
EOF