#!/bin/bash

apt update -y

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

declare -A apps=(
    ["app1"]="app-one-html /vagrant_shared/app1"
    ["app2"]="app-two-html /vagrant_shared/app2"
    ["app3"]="app-three-html /vagrant_shared/app3"
)

for app in "${!apps[@]}"; do
    IFS=" " read -r configmap_name path <<< "${apps[$app]}"
    echo "[$app] - Initiating..."
    kubectl create configmap "${configmap_name}" --from-file="${path}/index.html"
    kubectl apply -f "${path}/deployment.yaml"
    kubectl apply -f "${path}/service.yaml"
    echo "[$app] - Done"
done

echo "[Ingress] - Initiating..."
kubectl apply -f /vagrant_shared/ingress.yaml
echo "[Ingress] - Done"
