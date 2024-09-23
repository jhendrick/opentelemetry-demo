#!/bin/bash

if [[ -z $DT_TOKEN || -z $DT_ENDPOINT ]] then
    echo "Required variables DT_TOKEN and DT_ENDPOINT are not set. Exiting..."
    exit 1
fi

kind create cluster --config .devcontainer/kind-cluster.yaml --wait 300s

# ENV var pre-processing
# remove trailing slash on DT_ENDPOINT if it exists
DT_ENDPOINT=$(echo "$DT_ENDPOINT" | sed "s,/$,,")
echo "Removed any trailing slashes in DT_ENDPOINT"
# Base64 encode DT_TOKEN, remove newlines that are auto added
DT_TOKEN=$(echo -n $DT_TOKEN | base64 -w 0)

# install the Dynatrace operator
helm install dynatrace-operator oci://public.ecr.aws/dynatrace/dynatrace-operator \
    --create-namespace \
    --namespace dynatrace \
    --atomic

# Apply the Dynakube in ApplicationOnly mode
# using envsubst for env var replacement
envsubst < .devcontainer/dynakube.yaml | kubectl apply -f -
