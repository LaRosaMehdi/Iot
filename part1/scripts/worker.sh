#!/bin/bash

apt update -y
apt-get install -y curl
RETRY_COUNT=10
until [ -f "/vagrant_shared/token" ] || [ "$RETRY_COUNT" -eq 0 ]; do
    sleep 1
    RETRY_COUNT=$((RETRY_COUNT - 1))
done
if [ "$RETRY_COUNT" -eq 0 ]; then
    echo "NO Token Has Been Found"
    exit 1
fi
echo "[LOG] - Install of k3s into the worker node"
echo "[LOG] - The master node is Master node: $1"
export K3S_TOKEN_FILE=/vagrant_shared/token
export K3S_URL=https://$1:6443
export INSTALL_K3S_EXEC="--flannel-iface=eth1"
curl -sfL https://get.k3s.io | sh -


