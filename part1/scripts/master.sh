#!/bin/bash

# Mise à jour de base
apt update -y

# Installation de k3s
echo "[LOG] - Installing k3s into the master node"
K3S_OPTIONS="server --node-external-ip=$1 --bind-address=$1 --flannel-iface=eth1"
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="$K3S_OPTIONS" sh -

if ! command -v k3s >/dev/null 2>&1; then
    echo "[ERROR] - Installation of k3s failed."
    exit 1
fi

echo "[LOG] - Adjusting kubeconfig permissions"
KUBECONFIG_FILE="/etc/rancher/k3s/k3s.yaml"
if [ -f "$KUBECONFIG_FILE" ]; then
    sudo chmod 644 "$KUBECONFIG_FILE"
    sudo chown vagrant:vagrant "$KUBECONFIG_FILE"
    echo "[LOG] - Permissions adjusted for kubeconfig"
else
    echo "[ERROR] - kubeconfig file not found."
    exit 1
fi

echo "[LOG] - Sharing token"
for attempt in {1..30}; do
    if [ -f /var/lib/rancher/k3s/server/node-token ]; then
        cp /var/lib/rancher/k3s/server/node-token /vagrant_shared/token
        echo "[LOG] - Token shared successfully."
        exit 0
    fi
    sleep 1
done

echo "[ERROR] - Token file not generated after 30 attempts."
exit 1
