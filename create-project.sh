#!/bin/bash

if [[ -z "$1" ]]; then
  echo "You have to pass PROJECTNAME (optionally, shipyard) as arguments"
  echo "usage: ./setup-project.sh demo [./configs/shipyard.yaml]"
  exit 1
fi

if [[ "$2" == "" ]]; then
  SHIPYARD=./configs/shipyard.yaml
else
  SHIPYARD=$2
fi

GIT_USER=""
read -p "Enter git username: " GIT_USER
GIT_TOKEN=""
read -p "Enter git personal access token with repo access: " GIT_TOKEN
GIT_REMOTE_URL=""
read -p "Enter remote url of your empty git repo: " GIT_USER

if [[ -z "$GIT_USER" || -z "$GIT_TOKEN" || -z "$GIT_REMOTE_URL" ]]; then
  echo "Username, token, or remote repo was not set or was blank"
  exit 1
fi

# Setup Project
PROJECTNAME=$1

keptn create project $PROJECTNAME --shipyard $SHIPYARD --git-user $GIT_USER --git-token $GIT_TOKEN --git-remote-url $GIT_REMOTE_URL
