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

## 🎨 **Prompt Nanobana pour le diagramme**
```
Create Azure Firewall Hub-and-Spoke architecture diagram:

CENTER: Azure Firewall icon with shield
Label: "Azure Firewall (10.0.1.4)"
Show two collections:
  - Application Rules (Priority 100): Allow www.bing.com
  - Network Rules (Priority 200): Allow DNS port 53

LEFT SIDE: Spoke 1 VNet
- Rectangle: "Workload-SN (10.0.2.0/24)"
- VM icon: "Srv-Work"
- Route Table icon attached: "0.0.0.0/0 → 10.0.1.4"

RIGHT SIDE: Spoke 2 VNet (optional)
- Similar structure

BOTTOM: On-Premises connection
- VPN Gateway icon
- Label: "Site-to-Site VPN"

TRAFFIC FLOWS:
1. GREEN arrow: Srv-Work → Firewall → www.bing.com
   Label: "✅ Allowed by App Rule 100"
2. RED arrow: Srv-Work → Firewall → www.microsoft.com (blocked)
   Label: "❌ Denied (No rule matched)"
3. GREEN arrow: Srv-Work → Firewall → DNS (8.8.8.8)
   Label: "✅ Allowed by Network Rule 200"

CALLOUTS:
- "UDR forces ALL traffic through Firewall"
- "Layer 7 FQDN filtering"
- "Implicit Deny model"

Use Azure official icons, hub-spoke topology layout
