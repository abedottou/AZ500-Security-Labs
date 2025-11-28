#!/bin/bash
#
# Create NSG rules using Application Security Groups as destinations
# Demonstrates role-based filtering
#

# Variables
RESOURCE_GROUP="AZ500LAB02"
NSG_NAME="myNsg"
ASG_WEB="myAsgWebServers"
ASG_MGMT="myAsgMgmtServers"

echo "🔒 Creating NSG rules with ASG destinations..."

# Get ASG IDs
ASG_WEB_ID=$(az network asg show \
  --resource-group $RESOURCE_GROUP \
  --name $ASG_WEB \
  --query id \
  --output tsv)

ASG_MGMT_ID=$(az network asg show \
  --resource-group $RESOURCE_GROUP \
  --name $ASG_MGMT \
  --query id \
  --output tsv)

# Rule 1: Allow HTTP/HTTPS to Web Servers ASG
az network nsg rule create \
  --resource-group $RESOURCE_GROUP \
  --nsg-name $NSG_NAME \
  --name Allow-Web-Traffic \
  --priority 100 \
  --source-address-prefixes '*' \
  --source-port-ranges '*' \
  --destination-asgs $ASG_WEB \
  --destination-port-ranges 80 443 \
  --protocol Tcp \
  --access Allow \
  --direction Inbound \
  --description "Allow HTTP/HTTPS to web servers"

echo "✅ Rule 100: Allow HTTP/HTTPS to $ASG_WEB"

# Rule 2: Allow RDP to Management Servers ASG
az network nsg rule create \
  --resource-group $RESOURCE_GROUP \
  --nsg-name $NSG_NAME \
  --name Allow-RDP-Mgmt \
  --priority 110 \
  --source-address-prefixes '*' \
  --source-port-ranges '*' \
  --destination-asgs $ASG_MGMT \
  --destination-port-ranges 3389 \
  --protocol Tcp \
  --access Allow \
  --direction Inbound \
  --description "Allow RDP to management servers"

echo "✅ Rule 110: Allow RDP to $ASG_MGMT"

# Display configured rules
echo ""
echo "📊 NSG Rules Summary:"
az network nsg rule list \
  --resource-group $RESOURCE_GROUP \
  --nsg-name $NSG_NAME \
  --query "[?!name.starts_with(@, 'default')].{Priority:priority, Name:name, Access:access, Protocol:protocol, Ports:destinationPortRanges}" \
  --output table

echo ""
echo "🔑 Key Concept: Rules use ASG as destination, not IP addresses"
echo "   Adding new VMs to ASG automatically applies these rules"
