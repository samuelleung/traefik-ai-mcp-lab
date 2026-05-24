#!/bin/bash

set -e

CLUSTER_NAME="my-traefik-lab"

echo "Creating kind cluster: ${CLUSTER_NAME}"

if kind get clusters | grep -q "^${CLUSTER_NAME}$"; then
  echo "Cluster already exists: ${CLUSTER_NAME}"
else
  kind create cluster --name "${CLUSTER_NAME}"
fi

echo "Using context:"
kubectl config use-context "kind-${CLUSTER_NAME}"

echo "Creating namespaces..."
kubectl apply -f manifests/namespaces.yaml

echo "Applying Gateway API resources..."
kubectl apply -f manifests/gateway-api.yaml

echo "Applying Traefik CRDs/resources..."
kubectl apply -f manifests/traefik-crds.yaml

echo "Applying AI Gateway config..."
kubectl apply -f manifests/aigateway-configmaps.yaml

echo "Applying MCP config..."
kubectl apply -f manifests/mcp-configmaps.yaml

echo ""
echo "Cluster created/restored."
echo "Next:"
echo "  ./scripts/start-lab.sh"
