# Lab 05: Securing Azure SQL Database

## 🎯 Objective

Review and implement comprehensive security features for **Azure SQL Database**, focusing on threat protection, data classification, and audit logging for compliance (GDPR, HIPAA, PCI-DSS).

## 🏗️ Architecture

![Architecture Diagram](./diagrams/sql-database-security-architecture.png)

### Components:
- **Azure SQL Server**: Managed database server (az500l11xxxx)
- **Azure SQL Database**: AZ500LabDb (sample database)
- **Microsoft Defender for SQL**: Advanced threat protection
- **Data Discovery & Classification**: GDPR/compliance data labeling
- **SQL Auditing**: Server-level and database-level logging
- **Azure Storage Account**: Audit log storage (5-day retention)

### Security Features Implemented:
- ✅ **Advanced Threat Protection**: SQL injection detection, data exfiltration alerts
- ✅ **Data Classification**: Automatic discovery and labeling of sensitive columns
- ✅ **Server-Level Auditing**: All queries, stored procedures, logins
- ✅ **Database-Level Auditing**: Granular per-database logging
- ✅ **Vulnerability Assessment**: Automated security scans
- ✅ **Firewall Rules**: IP-based access control

---

## 📋 Prerequisites

- Azure subscription with Contributor access
- Azure PowerShell or Azure CLI
- SQL Server Management Studio (SSMS) - optional
- Basic SQL knowledge

---

## 🔧 Lab Setup

### Task 1: Deploy Azure SQL Database (ARM Template)

**Deployment Method**: Azure Portal Custom Template
```json
// See scripts/azuredeploy.json

{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "serverName": {
      "type": "string",
      "defaultValue": "[concat('az500l11', uniqueString(resourceGroup().id))]",
      "metadata": {
        "description": "The name of the SQL logical server."
      }
    },
    "sqlDBName": {
      "type": "string",
      "defaultValue": "AZ500LabDb",
      "metadata": {
        "description": "The name of the SQL Database."
      }
    },
    "administratorLogin": {
      "type": "string",
      "defaultValue": "Student",
      "metadata": {
        "description": "The administrator username of the SQL logical server."
      }
    },
    "administratorLoginPassword": {
      "type": "securestring",
      "metadata": {
        "description": "The administrator password of the SQL logical server."
      }
    }
  },
  "variables": {},
  "resources": [
    {
      "type": "Microsoft.Sql/servers",
      "apiVersion": "2021-02-01-preview",
      "name": "[parameters('serverName')]",
      "location": "[resourceGroup().location]",
      "properties": {
        "administratorLogin": "[parameters('administratorLogin')]",
        "administratorLoginPassword": "[parameters('administratorLoginPassword')]",
        "version": "12.0"
      },
      "resources": [
        {
          "type": "databases",
          "apiVersion": "2021-02-01-preview",
          "name": "[parameters('sqlDBName')]",
          "location": "[resourceGroup().location]",
          "sku": {
            "name": "Basic",
            "tier": "Basic",
            "capacity": 5
          },
          "dependsOn": [
            "[resourceId('Microsoft.Sql/servers', parameters('serverName'))]"
          ],
          "properties": {
            "collation": "SQL_Latin1_General_CP1_CI_AS",
            "maxSizeBytes": 2147483648,
            "sampleName": "AdventureWorksLT"
          }
        },
        {
          "type": "firewallRules",
          "apiVersion": "2021-02-01-preview",
          "name": "AllowAllAzureIps",
          "location": "[resourceGroup().location]",
          "dependsOn": [
            "[resourceId('Microsoft.Sql/servers', parameters('serverName'))]"
          ],
          "properties": {
            "startIpAddress": "0.0.0.0",
            "endIpAddress": "0.0.0.0"
          }
        }
      ]
    }
  ],
  "outputs": {
    "serverName": {
      "type": "string",
      "value": "[parameters('serverName')]"
    },
    "databaseName": {
      "type": "string",
      "value": "[parameters('sqlDBName')]"
    }
  }
}
```

**Deploy via Portal**:
```
1. Portal → Search "Deploy a custom template"
2. Build your own template in the editor
3. Load file: azuredeploy.json
4. Save
5. Configure:
   - Resource Group: Create new "AZ500LAB11"
   - Location: East US
   - Administrator Password: Pa55w.rd1234 (or your secure password)
6. Review + Create → Create
7. Wait for deployment (~3-5 minutes)
```

**Deploy via PowerShell**:
```powershell
# See scripts/01-deploy-sql-infrastructure.ps1

$resourceGroupName = "AZ500LAB11"
$location = "eastus"
$templateFile = "azuredeploy.json"

# Create Resource Group
New-AzResourceGroup -Name $resourceGroupName -Location $location

# Deploy template
New-AzResourceGroupDeployment `
    -ResourceGroupName $resourceGroupName `
    -TemplateFile $templateFile `
    -administratorLoginPassword (ConvertTo-SecureString "Pa55w.rd1234" -AsPlainText -Force) `
    -Verbose
```

**Validation**:
```powershell
# Verify resources
Get-AzSqlServer -ResourceGroupName "AZ500LAB11"
Get-AzSqlDatabase -ResourceGroupName "AZ500LAB11" -ServerName "az500l11xxxx"

# Expected output:
# ServerName: az500l11xxxx
# DatabaseName: AZ500LabDb
# Status: Online
```

---

### Task 2: Configure Advanced Data Protection (Microsoft Defender for SQL)

**Portal Steps**:
```
1. Portal → Resource Groups → AZ500LAB11
2. Click SQL Server (az500l11xxxx)
3. Security section → Microsoft Defender for Cloud
4. Click "Enable Microsoft Defender for SQL"
5. Wait for notification: "Azure Defender for SQL has been successfully enabled"
6. Click (configure) next to "Microsoft Defender for SQL: Enabled"
7. Review settings:
   - Pricing: ~$15/server/month
   - Trial period: 30 days free
   - Vulnerability Assessment Settings
   - Advanced Threat Protection Settings
8. Back to Microsoft Defender for Cloud blade
9. Review sections:
   - Recommendations (may take 10-15 minutes to populate)
   - Security alerts
```

**PowerShell Configuration**:
```powershell
# See scripts/02-configure-defender.ps1

$resourceGroupName = "AZ500LAB11"
$serverName = "az500l11xxxx"  # Replace with your server name

# Enable Defender for SQL
Update-AzSqlServerAdvancedThreatProtectionSetting `
    -ResourceGroupName $resourceGroupName `
    -ServerName $serverName `
    -NotificationRecipientsEmails "admin@yourdomain.com" `
    -EmailAdmins $true

# Enable Vulnerability Assessment
$storageAccountName = "az500sqlaudit$(Get-Random -Maximum 99999)"
New-AzStorageAccount `
    -ResourceGroupName $resourceGroupName `
    -Name $storageAccountName `
    -Location "eastus" `
    -SkuName Standard_LRS

Update-AzSqlServerVulnerabilityAssessmentSetting `
    -ResourceGroupName $resourceGroupName `
    -ServerName $serverName `
    -StorageAccountName $storageAccountName `
    -RecurringScansInterval Weekly `
    -EmailAdmins $true
```

**Key Features Enabled**:

**Advanced Threat Protection**:
- ✅ SQL injection detection
- ✅ Anomalous database access patterns
- ✅ Potential data exfiltration
- ✅ Brute force attacks
- ✅ Suspicious application access

**Vulnerability Assessment**:
- ✅ Weekly automated scans
- ✅ Security best practices validation
- ✅ Misconfiguration detection
- ✅ Compliance checks (PCI, HIPAA, GDPR)
- ✅ Remediation recommendations

---

### Task 3: Configure Data Classification (Data Discovery & Classification)

**Portal Steps**:
```
1. SQL Server blade → Settings → SQL Databases
2. Select "AZ500LabDb"
3. Security section → Data Discovery & Classification
4. Click "Classification" tab
5. Review message: "We have found 15 columns with classification recommendations"
6. Click blue bar message to view recommendations
7. Review recommended columns:
   - EmailAddress → Confidential - GDPR
   - Phone → Confidential - GDPR
   - PasswordHash → Confidential - Personal
   - etc.
8. Select all checkbox (or select specific columns)
9. Click "Accept Selected Recommendations"
10. Review and adjust:
    - Information Type (e.g., Email, Phone, SSN)
    - Sensitivity Label (Public, General, Confidential, Highly Confidential)
11. Click "Save"
12. Switch to "Overview" tab
13. Review classification statistics and charts
```

**SQL Query to View Classifications**:
```sql
-- See scripts/03-test-queries.sql

-- View classified columns
SELECT 
    SCHEMA_NAME(sys.objects.schema_id) AS SchemaName,
    sys.objects.name AS TableName,
    sys.columns.name AS ColumnName,
    sys.sensitivity_classifications.label AS SensitivityLabel,
    sys.sensitivity_classifications.information_type AS InformationType
FROM sys.sensitivity_classifications
INNER JOIN sys.objects ON sys.sensitivity_classifications.major_id = sys.objects.object_id
INNER JOIN sys.columns ON 
    sys.sensitivity_classifications.major_id = sys.columns.object_id
    AND sys.sensitivity_classifications.minor_id = sys.columns.column_id;

-- Expected output:
-- SchemaName | TableName  | ColumnName     | SensitivityLabel | InformationType
-- -----------|------------|----------------|------------------|----------------
-- SalesLT    | Customer   | EmailAddress   | Confidential     | Contact Info
-- SalesLT    | Customer   | Phone          | Confidential     | Contact Info
-- SalesLT    | Customer   | PasswordHash   | Confidential     | Credentials
```

**Classification Labels**:

| Sensitivity Label | Use Case | Example Columns |
|-------------------|----------|-----------------|
| **Public** | No restrictions | ProductName, CategoryName |
| **General** | Internal use | EmployeeID, OrderID |
| **Confidential** | Restricted access | Email, Phone, Address |
| **Highly Confidential** | Maximum protection | SSN, CreditCard, PasswordHash |

**Information Types**:
- Contact Info (Email, Phone)
- Credentials (Password, API Key)
- Financial (Credit Card, Bank Account)
- National ID (SSN, Passport Number)
- Name (First Name, Last Name)

---

### Task 4: Configure Auditing (Server-Level and Database-Level)

#### **Step 1: Server-Level Auditing**

**Portal Steps**:
```
1. Navigate to SQL Server blade (az500l11xxxx)
2. Security section → Auditing
3. Toggle "Enable Azure SQL Auditing" to ON
4. Select "Storage" checkbox
5. Subscription: Select your subscription
6. Storage Account: Click "Create new"
   - Name: az500sqlaudit[random] (globally unique)
   - Performance: Standard
   - Replication: LRS
   - Click OK
7. Wait for storage account to be created (refresh if needed)
8. Advanced properties:
   - Retention (days): 5
9. Click "Save"
```

**PowerShell Configuration**:
```powershell
# Create storage account for auditing
$storageAccountName = "az500sqlaudit$(Get-Random -Maximum 99999)"
$storageAccount = New-AzStorageAccount `
    -ResourceGroupName "AZ500LAB11" `
    -Name $storageAccountName `
    -Location "eastus" `
    -SkuName Standard_LRS

# Enable server-level auditing
Set-AzSqlServerAudit `
    -ResourceGroupName "AZ500LAB11" `
    -ServerName "az500l11xxxx" `
    -BlobStorageTargetState Enabled `
    -StorageAccountResourceId $storageAccount.Id `
    -RetentionInDays 5
```

**Audit Events Captured** (Server-Level):
- ✅ All queries and stored procedures
- ✅ Successful logins
- ✅ Failed logins
- ✅ Database schema changes (DDL)
- ✅ Permission changes (GRANT, REVOKE)
- ✅ Backup/restore operations

---

#### **Step 2: Database-Level Auditing**

**Portal Steps**:
```
1. SQL Server → Settings → SQL Databases
2. Select "AZ500LabDb"
3. Security section → Auditing
4. Note: "Server-level auditing is already enabled"
5. Options to write audits:
   - ✅ Storage account (already configured at server level)
   - ☐ Log Analytics workspace (optional)
   - ☐ Event Hub (optional)
6. Database-level auditing inherits server settings
7. Can add additional destinations (Log Analytics, Event Hub)
```

**Additional Destination: Log Analytics** (Optional):
```powershell
# Create Log Analytics Workspace
$workspaceName = "AZ500SQLAuditWorkspace"
New-AzOperationalInsightsWorkspace `
    -ResourceGroupName "AZ500LAB11" `
    -Name $workspaceName `
    -Location "eastus" `
    -Sku PerGB2018

# Enable Log Analytics auditing
Set-AzSqlDatabaseAudit `
    -ResourceGroupName "AZ500LAB11" `
    -ServerName "az500l11xxxx" `
    -DatabaseName "AZ500LabDb" `
    -LogAnalyticsTargetState Enabled `
    -WorkspaceResourceId (Get-AzOperationalInsightsWorkspace -ResourceGroupName "AZ500LAB11" -Name $workspaceName).ResourceId
```

---

#### **Step 3: Test Auditing with Query Editor**

**Portal Steps**:
