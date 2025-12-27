#!/bin/bash
# Lab 04 - Azure Container Registry Setup
# Description: Creates ACR and builds nginx image

set -e  # Exit on error

# Variables
RG_NAME="AZ500LAB04"
LOCATION="eastus"
ACR_NAME="acraz500$RANDOM"

echo "========================================="
echo " Azure Container Registry Setup"
echo "========================================="

# Create Resource Group
echo "[1/4] Creating Resource Group: $RG_NAME..."
az group create \
    --name $RG_NAME \
    --location $LOCATION \
    --output none

# Create ACR
echo "[2/4] Creating Azure Container Registry: $ACR_NAME..."
az acr create \
    --resource-group $RG_NAME \
    --name $ACR_NAME \
    --sku Basic \
    --admin-enabled false \
    --output none

# Build and push nginx image
echo "[3/4] Building nginx image in ACR..."
cat <<EOF | az acr build --registry $ACR_NAME --image nginx:v1 --file - .
FROM nginx:alpine
RUN echo '<h1>Hello from AKS - Secured with ACR</h1>' > /usr/share/nginx/html/index.html
RUN echo '<p>Image pulled from private Azure Container Registry</p>' >> /usr/share/nginx/html/index.html
RUN echo '<p>Authenticated via AKS Managed Identity</p>' >> /usr/share/nginx/html/index.html
EXPOSE 80
EOF

# Verify images
echo "[4/4] Verifying images in ACR..."
echo ""
echo "Images in ACR:"
az acr repository list --name $ACR_NAME --output table
echo ""
echo "Tags for nginx:"
az acr repository show-tags --name $ACR_NAME --repository nginx --output table

echo ""
echo "========================================="
echo " ACR Setup Complete!"
echo "========================================="
echo "ACR Name: $ACR_NAME"
echo "Login Server: ${ACR_NAME}.azurecr.io"
echo "Resource Group: $RG_NAME"
echo ""
echo "Save ACR_NAME for next step:"
echo "export ACR_NAME=$ACR_NAME"
echo "========================================="
