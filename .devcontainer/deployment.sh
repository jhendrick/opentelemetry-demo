#!/usr/bin/env bash

if [ -z "${DT_TOKEN}" || -z "${DT_ENDPOINT}"]; then
    echo "Required variables DT_TOKEN and DT_ENDPOINT are not set. Exiting..."
    exit 1
fi

kind create cluster --config .devcontainer/kind-cluster.yaml --wait 300s

# replace token and endpoint with user provided values
sed -i -e 's/DT_TOKEN/'"$DT_TOKEN"'/g' dynakube.yaml 
sed -i -e 's/DT_ENDPOINT/'"$DT_ENDPOINT"'/g' dynakube.yaml

# install the Dynatrace operator
helm install dynatrace-operator oci://public.ecr.aws/dynatrace/dynatrace-operator \
    --create-namespace \
    --namespace dynatrace \
    --atomic

# Apply the Dynakube in ApplicationOnly mode
kubectl apply -f dynakube.yaml
