#!/bin/bash

kind create cluster --config .devcontainer/kind-cluster.yaml --wait 300s
