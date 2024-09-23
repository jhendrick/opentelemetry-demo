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
DT_OPERATOR_TOKEN=$(echo -n $DT_OPERATOR_TOKEN | base64 -w 0)
#DT_API_TOKEN=$(echo -n $DT_API_TOKEN | base64 -w 0)

# install the Dynatrace operator
helm install dynatrace-operator oci://public.ecr.aws/dynatrace/dynatrace-operator \
    --create-namespace \
    --namespace dynatrace \
    --atomic

# Apply the Dynakube in ApplicationOnly mode
# using envsubst for env var replacement
envsubst < .devcontainer/dynakube.yaml | kubectl apply -f -

# create Otel collector credentials
kubectl create secret generic dynatrace-otelcol-dt-api-credentials \
--from-literal=DT_ENDPOINT=$DT_ENDPOINT/api/v2/otlp \
--from-literal=DT_API_TOKEN=$DT_API_TOKEN

# Add OpenTelemetry Helm Charts
helm repo add open-telemetry https://open-telemetry.github.io/opentelemetry-helm-charts
helm repo update

# Install Dynatrace Otel Collector
helm upgrade -i dynatrace-collector open-telemetry/opentelemetry-collector -f .devcontainer/collector-values.yaml

# Install the Otel demo app
helm upgrade -i my-otel-demo open-telemetry/opentelemetry-demo -f .devcontainer/otel-demo-values.yaml
