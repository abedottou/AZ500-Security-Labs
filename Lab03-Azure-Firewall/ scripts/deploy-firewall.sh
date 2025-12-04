#!/bin/bash
#
# Deploy Azure Firewall infrastructure for Lab 03
# Author: [Your Name]
# Part of AZ-500 Labs
#

set -e

# Variables
RESOURCE_GROUP="AZ500LAB09"
LOCATION="eastus"
VNET_NAME="VNet-Hub"
VNET_PREFIX="10.0.0.0/16"
FW_SUBNET="AzureFirewallSubnet"
FW_SUBNET_PREFIX="10.0.1.0/26"
WORKLOAD_SUBNET="Workload-SN"
WORKLOAD_SUBNET_PREFIX="10.0.2.0/24"
FIREWALL_NAME="AzureFirewall"
FIREWALL_PIP="AzFW-PIP"

echo "🚀 Starting Azure Firewall deployment..."

# Create Resource Group
echo "📦 Creating Resource Group..."
az group create \
  --name $RESOURCE_GROUP \
  --location $LOCATION

# Create Virtual Network
echo "🌐 Creating Virtual Network..."
az network vnet create \
  --resource-group $RESOURCE_GROUP \
  --name $VNET_NAME \
  --address-prefix $VNET_PREFIX \
  --location $LOCATION

# Create AzureFirewallSubnet (name must be exact)
echo "🔥 Creating AzureFirewallSubnet..."
az network vnet subnet create \
  --resource-group $RESOURCE_GROUP \
  --vnet-name $VNET_NAME \
  --name $FW_SUBNET \
  --address-prefix $FW_SUBNET_PREFIX

# Create Workload Subnet
echo "💼 Creating Workload Subnet..."
az network vnet subnet create \
  --resource-group $RESOURCE_GROUP \
  --vnet-name $VNET_NAME \
  --name $WORKLOAD_SUBNET \
  --address-prefix $WORKLOAD_SUBNET_PREFIX

# Create Public IP for Firewall
echo "🌍 Creating Firewall Public IP..."
az network public-ip create \
  --resource-group $RESOURCE_GROUP \
  --name $FIREWALL_PIP \
  --location $LOCATION \
  --allocation-method Static \
  --sku Standard

# Deploy Azure Firewall
echo "🔥 Deploying Azure Firewall (this takes 5-10 minutes)..."
az network firewall create \
  --resource-group $RESOURCE_GROUP \
  --name $FIREWALL_NAME \
  --location $LOCATION

# Configure Firewall IP
echo "⚙️  Configuring Firewall IP..."
az network firewall ip-config create \
  --resource-group $RESOURCE_GROUP \
  --firewall-name $FIREWALL_NAME \
  --name FW-IpConfig \
  --public-ip-address $FIREWALL_PIP \
  --vnet-name $VNET_NAME

# Get Firewall Private IP
FW_PRIVATE_IP=$(az network firewall show \
  --resource-group $RESOURCE_GROUP \
  --name $FIREWALL_NAME \
  --query 'ipConfigurations[0].privateIPAddress' \
  --output tsv)

echo "✅ Firewall deployed successfully!"
echo "📋 Firewall Private IP: $FW_PRIVATE_IP"
echo ""
echo "Next steps:"
echo "1. Run configure-rules.sh to add firewall rules"
echo "2. Deploy test VM in Workload subnet"
echo "3. Create Route Table pointing to $FW_PRIVATE_IP"
