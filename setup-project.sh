#!/bin/bash

# Setup Project
git clone https://github.com/paradoxinversion/containerized-node-app-helm-chart.git
helm package containerized-node-app-helm-chart
sudo echo PROJECTNAME=demo >> $BASHRC
sudo echo SERVICENAME=demo-svc >> $BASHRC
sudo echo HELM_CHART=./demo-0.1.0 >> $BASHRC
source $BASHRC

keptn create project $PROJECTNAME --shipyard="./configs/shipyard.yaml"
keptn create service $SERVICENAME --project=$PROJECTNAME
keptn add-resource --project=$PROJECTNAME --service=$SERVICENAME --all-stages --resource=$HELM_CHART.tgz --resourceUri=helm/$SERVICENAME.tgz