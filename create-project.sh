$PROJECTNAME=demo
$SERVICENAME=demo-svc
$HELM_CHART=./demo-svc-0.1.0
keptn create project $PROJECTNAME --shipyard="./configs/shipyard.yaml"
keptn create service $SERVICENAME --project=$PROJECTNAME
keptn add-resource --project=$PROJECTNAME --service=$SERVICENAME --all-stages --resource=$HELM_CHART.tgz --resourceUri=helm/$SERVICENAME.tgz
