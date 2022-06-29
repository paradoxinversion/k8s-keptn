#!/bin/bash
if [ -z "$PROJECTNAME" ]; then
 	echo "No PROJECTNAME var could be found. Please ensure it exists."
	exit 1
fi

if [ -z "$SERVICENAME" ]; then
 	echo "No SERVICENAME var could be found. Please ensure it exists."
	exit 1
fi
keptn trigger delivery --project $PROJECTNAME --service $SERVICENAME --image docker.io/paradoxinversion/containerized-node-app:latest
