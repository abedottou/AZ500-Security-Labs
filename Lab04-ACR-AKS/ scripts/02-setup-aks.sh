#!/bin/bash
# Lab 04 - Azure Kubernetes Service Setup
# Description: Creates AKS cluster and integrates with ACR

set -e

# Variables (reuse from previous script)
RG_NAME="AZ500LAB04"
AKS_CLUSTER_NAME="AKSCluster"
NODE_COUNT=2
NODE_SIZE="Standard_DS2_v2"
K8S_VERSION="1.27"

# Check if ACR_NAME is set
if [ -z "$ACR_NAME" ]; then
    echo "Error: ACR_NAME not set. Run: export ACR_NAME=<your-acr-name>"
    exit 1
fi

echo "========================================="
echo " Azure Kubernetes Service Setup"
echo "========================================="

# Create AKS cluster
echo "[1/3] Creating AKS cluster: $AKS_CLUSTER_NAME..."
echo "This may take 5-10 minutes..."
az aks create \
    --resource-group $RG_NAME \
    --name $AKS_CLUSTER_NAME \
    --node-count $NODE_COUNT \
    --node-vm-size $NODE_SIZE \
    --kubernetes-version $K8S_VERSION \
    --network-plugin azure \
    --generate-ssh-keys \
    --enable-managed-identity \
    --output none

# Integrate with ACR
echo "[2/3] Integrating AKS with ACR..."
az aks update \
    --resource-group $RG_NAME \
    --name $AKS_CLUSTER_NAME \
    --attach-acr $ACR_NAME \
    --output none

# Get credentials
echo "[3/3] Getting AKS credentials..."
az aks get-credentials \
    --resource-group $RG_NAME \
    --name $AKS_CLUSTER_NAME \
    --overwrite-existing

# Verify
echo ""
echo "========================================="
echo " AKS Cluster Ready!"
echo "========================================="
echo "Cluster nodes:"
kubectl get nodes
echo ""
echo "Cluster info:"
kubectl cluster-info
echo "========================================="
