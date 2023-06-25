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

# save ca.crt, cert.key, and cert.cert to /usr/local/share/certificates
if [[ $CHARTMUSEUM_CA_CRT ]]; then
  echo $CHARTMUSEUM_CA_CRT | base64 -d > /usr/local/share/certificates/ca.crt
fi

if [[ $CHARTMUSEUM_KEY ]]; then
  echo $CHARTMUSEUM_KEY | base64 -d > /usr/local/share/certificates/cert.key
fi

if [[ $CHARTMUSEUM_CERT ]]; then
  echo $CHARTMUSEUM_CERT | base64 -d > /usr/local/share/certificates/cert.cert
fi

for CHART_PATH in $PATHS; do
  cd $CHART_PATH

  helm version -c

  helm inspect chart .

  if [[ $CHARTMUSEUM_REPO_NAME ]]; then
    helm repo add ${CHARTMUSEUM_REPO_NAME} ${CHARTMUSEUM_URL} --ca-file /usr/local/share/ca-certificates/ca.crt --cert-file /usr/local/share/certificates/cert.crt --key-file /usr/local/share/certificates/cert.key
  fi

  helm dependency update .

  helm package .

  CHART_FOLDER=$(basename "$CHART_PATH")

  export HELM_REPO_ACCESS_TOKEN="${CHARTMUSEUM_JWT}"
  
  helm cm-push ${CHART_FOLDER}-* ${CHARTMUSEUM_URL} ${FORCE} --ca-file /usr/local/share/ca-certificates/ca.crt --cert-file /usr/local/share/certificates/cert.crt --key-file /usr/local/share/certificates/cert.key

  # Return to the original working directory at the end of each loop iteration
  cd $orig_dir
done
