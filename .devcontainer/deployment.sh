#!/bin/bash

if [[ -z $DT_TOKEN || -z $DT_ENDPOINT ]] then
    echo "Required variables DT_TOKEN and DT_ENDPOINT are not set. Exiting..."
    exit 1
fi

kind create cluster --config .devcontainer/kind-cluster.yaml --wait 300s

# remove trailing slash on DT_ENDPOINT if it exists
#DT_ENDPOINT=$(echo "$DT_ENDPOINT" | sed "s,/$,,")
#echo "Removed trailing slashes in $DT_ENDPOINT"

# replace the endpoint with user provided value
# sed -i "s|DT_ENDPOINT|$DT_ENDPOINT|" .devcontainer/dynakube.yaml

# install the Dynatrace operator
helm install dynatrace-operator oci://public.ecr.aws/dynatrace/dynatrace-operator \
    --create-namespace \
    --namespace dynatrace \
    --atomic

# create the secret with the user provided API token
# kubectl -n dynatrace create secret generic kind-k8s --from-literal="apiToken=$DT_TOKEN"

# Apply the Dynakube in ApplicationOnly mode
kubectl apply -f .devcontainer/dynakube.yaml
