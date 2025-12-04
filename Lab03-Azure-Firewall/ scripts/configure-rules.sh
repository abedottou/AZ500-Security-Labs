#!/bin/bash
#
# Configure Azure Firewall Application and Network Rules
#

RESOURCE_GROUP="AZ500LAB09"
FIREWALL_NAME="AzureFirewall"
SOURCE_SUBNET="10.0.2.0/24"

echo "🔒 Configuring Firewall Rules..."

# Application Rule: Allow Bing
echo "📱 Creating Application Rule..."
az network firewall application-rule create \
  --resource-group $RESOURCE_GROUP \
  --firewall-name $FIREWALL_NAME \
  --collection-name AppRules-Allow \
  --name Allow-Bing \
  --protocols Http=80 Https=443 \
  --target-fqdns www.bing.com \
  --source-addresses $SOURCE_SUBNET \
  --priority 100 \
  --action Allow

echo "✅ Application Rule created"

# Network Rule: Allow DNS
echo "🌐 Creating Network Rule..."
az network firewall network-rule create \
  --resource-group $RESOURCE_GROUP \
  --firewall-name $FIREWALL_NAME \
  --collection-name NetRules-Allow \
  --name Allow-DNS \
  --protocols UDP \
  --destination-ports 53 \
  --destination-addresses 8.8.8.8 8.8.4.4 \
  --source-addresses $SOURCE_SUBNET \
  --priority 200 \
  --action Allow

echo "✅ Network Rule created"
echo "🎉 Firewall configuration complete!"
```

---

