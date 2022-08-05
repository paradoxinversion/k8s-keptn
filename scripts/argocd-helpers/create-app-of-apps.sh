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
argocd app sync containerized-node-app  