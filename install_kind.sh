#!/bin/bash
set -e

echo "📦 Updating packages..."
sudo apt update -y && sudo apt upgrade -y

echo "🐳 Installing Docker..."
sudo apt install -y docker.io
sudo systemctl enable docker
sudo systemctl start docker

echo "🔐 Adding current user to docker group..."
sudo usermod -aG docker $USER
echo "⚠️ Please log out and log back in for Docker group permissions to take effect."

echo "📦 Installing kubectl (v1.30.1)..."
curl -LO "https://dl.k8s.io/release/v1.30.1/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/

echo "🧱 Installing Kind (v0.23.0)..."
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.23.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind

echo "🧾 Creating Kind config file for 1 control-plane + 3 workers..."
cat <<EOF > kind-config.yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
  - role: control-plane
  - role: worker
  - role: worker
  - role: worker
EOF

echo "🚀 Creating Kind cluster with multi-node setup..."
kind create cluster --config kind-config.yaml

echo "🔎 Verifying Kubernetes nodes..."
kubectl get nodes

echo "✅ Kind cluster with 1 control-plane and 3 workers is ready!"
