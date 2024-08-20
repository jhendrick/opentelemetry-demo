#!/bin/bash

# copy config to user dir to use helm 
cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
chown $(id -u):$(id -g) ~/.kube/config

# deploy
chmod +x .devcontainer/deployment.sh && .devcontainer/deployment.sh
