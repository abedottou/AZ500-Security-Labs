#!/bin/bash
#
# Create NSG and ASG configuration for Lab 02
# Demonstrates tag-based network filtering
# Author: [Your Name]
#

# Variables
RESOURCE_GROUP="AZ500LAB02"
LOCATION="eastus"
VNET_NAME="myVNet"
SUBNET_NAME="default"
NSG_NAME="myNsg"
ASG_WEB="myAsgWebServers"
ASG_MGMT="myAsgMgmtServers"

echo "🔧 Creating Network Security Group and Application Security Groups..."

# Create Resource Group
az group create \
  --name $RESOURCE_GROUP \
  --location $LOCATION

# Create Virtual Network
az network vnet create \
  --resource-group $RESOURCE_GROUP \
  --name $VNET_NAME \
  --address-prefix 10.0.0.0/16 \
  --subnet-name $SUBNET_NAME \
  --subnet-prefix 10.0.0.0/24

# Create Network Security Group
az network nsg create \
  --resource-group $RESOURCE_GROUP \
  --name $NSG_NAME \
  --location $LOCATION

echo "✅ NSG created: $NSG_NAME"

# Create Application Security Groups
az network asg create \
  --resource-group $RESOURCE_GROUP \
  --name $ASG_WEB \
  --location $LOCATION

az network asg create \
  --resource-group $RESOURCE_GROUP \
  --name $ASG_MGMT \
  --location $LOCATION

echo "✅ ASGs created: $ASG_WEB, $ASG_MGMT"

# Associate NSG with Subnet
az network vnet subnet update \
  --resource-group $RESOURCE_GROUP \
  --vnet-name $VNET_NAME \
  --name $SUBNET_NAME \
  --network-security-group $NSG_NAME

echo "✅ NSG associated with subnet"
echo "📋 Setup complete. Run create-nsg-rules.sh to add security rules."
