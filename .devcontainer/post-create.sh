#!/bin/bash

kind create cluster --config .devcontainer/kind-cluster.yml --wait 300s

# deploy
# chmod +x .devcontainer/deployment.sh && .devcontainer/deployment.sh
