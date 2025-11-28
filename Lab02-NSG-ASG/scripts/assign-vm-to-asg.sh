#!/bin/bash
#
# Assign VM network interfaces to Application Security Groups
# This enables tag-based filtering
#

# Variables
RESOURCE_GROUP="AZ500LAB02"
VM_WEB="myVMWeb"
VM_MGMT="myVMMgmt"
ASG_WEB="myAsgWebServers"
ASG_MGMT="myAsgMgmtServers"

echo "🏷️  Assigning VMs to Application Security Groups..."

# Get NIC IDs
NIC_WEB=$(az vm show \
  --resource-group $RESOURCE_GROUP \
  --name $VM_WEB \
  --query 'networkProfile.networkInterfaces[0].id' \
  --output tsv)

NIC_MGMT=$(az vm show \
  --resource-group $RESOURCE_GROUP \
  --name $VM_MGMT \
  --query 'networkProfile.networkInterfaces[0].id' \
  --output tsv)

# Assign Web VM NIC to Web Servers ASG
az network nic ip-config update \
  --resource-group $RESOURCE_GROUP \
  --nic-name $(basename $NIC_WEB) \
  --name ipconfig1 \
  --application-security-groups $ASG_WEB

echo "✅ $VM_WEB NIC assigned to $ASG_WEB"

# Assign Management VM NIC to Management Servers ASG
az network nic ip-config update \
  --resource-group $RESOURCE_GROUP \
  --nic-name $(basename $NIC_MGMT) \
  --name ipconfig1 \
  --application-security-groups $ASG_MGMT

echo "✅ $VM_MGMT NIC assigned to $ASG_MGMT"

echo ""
echo "🎯 Result: NSG rules now apply based on ASG membership"
echo "   $VM_WEB → allows ports 80, 443"
echo "   $VM_MGMT → allows port 3389"
```

---

### 🎨 Prompt pour Nanobana
```
Create an Azure NSG and ASG network security diagram:

LAYOUT: Top-down network architecture view

TOP SECTION - Internet/External:
- Cloud icon labeled "Internet"
- Show incoming traffic arrows (HTTP, HTTPS, RDP attempts)

MIDDLE SECTION - Azure Virtual Network:
- Large box labeled "myVNet (10.0.0.0/16)"
- Inside VNet, a subnet box labeled "default subnet (10.0.0.0/24)"
- NSG icon attached to subnet labeled "myNsg"

NSG RULES (shown as a rule table next to NSG):
- Priority 100: Allow TCP 80,443 → myAsgWebServers
- Priority 110: Allow TCP 3389 → myAsgMgmtServers
- Priority 65500: Deny All (shown grayed out)

INSIDE SUBNET - Application Security Groups:
- Two dashed containers representing ASGs:

  Container 1 - "myAsgWebServers" (blue dashed box):
  - VM icon labeled "myVMWeb"
  - Tag icon showing "Ports: 80, 443"

  Container 2 - "myAsgMgmtServers" (green dashed box):
  - VM icon labeled "myVMMgmt"
  - Tag icon showing "Port: 3389"

TRAFFIC FLOW ARROWS:
1. Internet → Port 80/443 → myVMWeb (green arrow, checkmark, "Allowed by Rule 100")
2. Internet → Port 3389 → myVMWeb (red arrow, X, "Denied - No rule match")
3. Internet → Port 3389 → myVMMgmt (green arrow, checkmark, "Allowed by Rule 110")
4. Internet → Port 80 → myVMMgmt (red arrow, X, "Denied - No rule match")

CALLOUT BOXES (3 key concepts):
1. "NSG attached at subnet level - applies to all VMs"
2. "ASG = Tag-based filtering - scalable, no IP management"
3. "Implicit Deny (Rule 65500) - only explicitly allowed traffic passes"

VISUAL STYLE:
- Use official Azure icons (VNet, NSG, VM, firewall)
- NSG shown as firewall icon at subnet boundary
- ASG shown as dashed containers (tags, not physical boundaries)
- Green arrows with checkmarks = allowed traffic
- Red arrows with X = denied traffic
- Blue color scheme for web tier
- Green color scheme for management tier
- Clear priority labels on rules (100, 110, 65500)

LEGEND:
- Solid box = Network boundary (VNet, Subnet)
- Dashed box = Application Security Group (logical grouping)
- Firewall icon = Network Security Group
- Green check = Traffic allowed
- Red X = Traffic denied
```

---

### 📁 Structure finale
```
Lab02-NSG-ASG/
├── README.md
├── nsg-asg-architecture.png
├── scripts/
│   ├── create-nsg-asg.sh
│   ├── create-nsg-rules.sh
│   └── assign-vm-to-asg.sh
└── NOTES.md (optionnel)
