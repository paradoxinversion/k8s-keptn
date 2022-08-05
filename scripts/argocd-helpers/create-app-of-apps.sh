argocd app create applications \
    --dest-namespace argocd \
    --dest-server https://kubernetes.default.svc \
    --repo https://github.com/paradoxinversion/cna-helm-chart-repo.git \
    --path app-of-apps  
argocd app sync applications  
