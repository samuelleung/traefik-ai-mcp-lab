#!/bin/bash

set -e

CLUSTER_NAME="my-traefik-lab"

echo "Stopping lab services first..."
./scripts/stop-lab.sh || true

echo ""
echo "Deleting kind cluster: ${CLUSTER_NAME}"
kind delete cluster --name "${CLUSTER_NAME}" || true

echo ""
echo "Lab cluster destroyed."
