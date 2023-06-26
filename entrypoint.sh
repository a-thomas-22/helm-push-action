#!/usr/bin/env bash

set -e
set -x

if [ -z "$PATHS" ]; then
  echo "PATHS is not set. Quitting."
  exit 1
fi

if [ -z "$CHARTMUSEUM_URL" ]; then
  echo "CHARTMUSEUM_URL is not set. Quitting."
  exit 1
fi

if [ -z "$FORCE" ]; then
  FORCE=""
elif [ "$FORCE" == "1" ] || [ "$FORCE" == "True" ] || [ "$FORCE" == "TRUE" ]; then
  FORCE="-f"
fi

# Store the original working directory
orig_dir=$(pwd)

#create certificates directory
mkdir -p $GITHUB_WORKSPACE

# save ca.crt, cert.key, and cert.crt to $GITHUB_WORKSPACE
if [[ $CHARTMUSEUM_CA_CERT ]]; then
  echo "CA_CRT is set. Saving to $GITHUB_WORKSPACE/ca.crt"
  echo $CHARTMUSEUM_CA_CERT | base64 -d > $GITHUB_WORKSPACE/ca.crt
fi

if [[ $CHARTMUSEUM_KEY ]]; then
  echo "KEY is set. Saving to $GITHUB_WORKSPACE/cert.key"
  echo $CHARTMUSEUM_KEY | base64 -d > $GITHUB_WORKSPACE/cert.key
fi

if [[ $CHARTMUSEUM_CERT ]]; then
  echo "CERT is set. Saving to $GITHUB_WORKSPACE/cert.crt"
  echo $CHARTMUSEUM_CERT | base64 -d > $GITHUB_WORKSPACE/cert.crt
fi

for CHART_PATH in $PATHS; do
  cd $CHART_PATH

  helm version -c

  helm inspect chart .

  if [[ $CHARTMUSEUM_REPO_NAME ]]; then
    helm repo add ${CHARTMUSEUM_REPO_NAME} ${CHARTMUSEUM_URL} --ca-file $GITHUB_WORKSPACE/ca.crt --cert-file $GITHUB_WORKSPACE/cert.crt --key-file $GITHUB_WORKSPACE/cert.key
  fi

  helm dependency update .

  helm package .

  CHART_FOLDER=$(basename "$CHART_PATH")

  export HELM_REPO_ACCESS_TOKEN="${CHARTMUSEUM_JWT}"
  
  helm cm-push ${CHART_FOLDER}-* ${CHARTMUSEUM_URL} ${FORCE} --ca-file $GITHUB_WORKSPACE/ca.crt --cert-file $GITHUB_WORKSPACE/cert.crt --key-file $GITHUB_WORKSPACE/cert.key

  # Return to the original working directory at the end of each loop iteration
  cd $orig_dir
done
