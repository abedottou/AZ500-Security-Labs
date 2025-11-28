#!/bin/bash
#
# Assign VM Contributor role to Service Desk group at Resource Group scope
# Demonstrates scope-limited RBAC assignment
# Part of AZ-500 Lab 01
#

# Variables
RESOURCE_GROUP="AZ500LAB01"
ROLE="Virtual Machine Contributor"
GROUP_NAME="Service Desk"

# Get the Object ID of the Service Desk group
GROUP_ID=$(az ad group show \
  --group "$GROUP_NAME" \
  --query id \
  --output tsv)

if [ -z "$GROUP_ID" ]; then
    echo "❌ Error: Could not find group '$GROUP_NAME'"
    exit 1
fi

echo "📋 Group ID: $GROUP_ID"

# Assign role at Resource Group scope
az role assignment create \
  --assignee "$GROUP_ID" \
  --role "$ROLE" \
  --resource-group "$RESOURCE_GROUP"

if [ $? -eq 0 ]; then
    echo "✅ Role '$ROLE' assigned to group '$GROUP_NAME' on Resource Group '$RESOURCE_GROUP'"
    echo "🔒 Scope: Resource Group level only"
else
    echo "❌ Error assigning role"
    exit 1
fi

# Verify assignment
echo ""
echo "📊 Verifying role assignment..."
az role assignment list \
  --resource-group "$RESOURCE_GROUP" \
  --assignee "$GROUP_ID" \
  --output table
```

---

### 📁 Structure finale du dossier
```
Lab01-RBAC/
├── README.md
├── rbac-architecture.png          (à créer avec Nanobana)
├── scripts/
│   ├── create-users-powershell.ps1
│   ├── create-users-cli.sh
│   └── assign-rbac-role.sh
└── VALIDATION.md                   (optionnel - voir ci-dessous)
