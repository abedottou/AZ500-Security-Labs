# Lab 03: Azure Firewall - Centralized Egress Control

## Objective
Deploy Azure Firewall as a central control point for outbound traffic using User-Defined Routes (UDR) to force all traffic through the firewall for inspection.

## Architecture

![Azure Firewall Architecture](./firewall-architecture.png)

**Hub-and-Spoke Model:**
- Central VNet with Azure Firewall
- Spoke VNets (Spoke 1, Spoke 2) with workload subnets
- UDR forces all outbound traffic (0.0.0.0/0) through firewall
- On-premises connectivity via VPN/ExpressRoute

## Components Deployed

### Networking
- **Virtual Network**: Central VNet with AzureFirewallSubnet
- **Spoke VNets**: Workload-SN subnets
- **Route Tables**: UDR with default route pointing to Firewall private IP

### Security
- **Azure Firewall**: Centralized traffic control
- **Application Rules**: Layer 7 FQDN filtering (allow www.bing.com only)
- **Network Rules**: Layer 3/4 filtering (allow DNS port 53)
- **NAT Rules**: Inbound DNAT, Outbound SNAT

### Compute
- **Srv-Work**: VM in Workload subnet (for testing)

## Key Features Demonstrated

### 1. User-Defined Routes (UDR)
```bash
Route Table: RT-Workload
Destination: 0.0.0.0/0 (all Internet traffic)
Next Hop: Azure Firewall Private IP (10.x.x.4)
Associated to: Workload-SN subnet
```
→ **Forced tunneling**: All outbound traffic MUST go through firewall

### 2. Application Rules (Layer 7)
```
Rule Collection: AppRules-Allow
Priority: 100
Rule: Allow-Bing
  - Target FQDN: www.bing.com
  - Protocol: HTTP, HTTPS (ports 80, 443)
  - Source: Workload-SN subnet
  - Action: Allow
```

### 3. Network Rules (Layer 3/4)
```
Rule Collection: NetRules-Allow
Priority: 200
Rule: Allow-DNS
  - Destination IPs: 8.8.8.8, 8.8.4.4 (Google DNS)
  - Protocol: UDP
  - Port: 53
  - Source: Workload-SN subnet
  - Action: Allow
```

## Configuration Steps

### Deploy Infrastructure
```bash
# Create Resource Group
az group create --name AZ500LAB09 --location eastus

# Deploy ARM template (creates VNet, Firewall, VMs)
az deployment group create \
  --resource-group AZ500LAB09 \
  --template-file azuredeploy.json
```

### Configure Route Table
```bash
# Create Route Table
az network route-table create \
  --name RT-Workload \
  --resource-group AZ500LAB09 \
  --location eastus

# Add default route to Firewall
az network route-table route create \
  --resource-group AZ500LAB09 \
  --route-table-name RT-Workload \
  --name Route-to-Firewall \
  --address-prefix 0.0.0.0/0 \
  --next-hop-type VirtualAppliance \
  --next-hop-ip-address 10.0.1.4

# Associate Route Table to Workload Subnet
az network vnet subnet update \
  --resource-group AZ500LAB09 \
  --vnet-name VNet-Hub \
  --name Workload-SN \
  --route-table RT-Workload
```

### Configure Firewall Rules
```bash
# Application Rule: Allow Bing
az network firewall application-rule create \
  --resource-group AZ500LAB09 \
  --firewall-name AzureFirewall \
  --collection-name AppRules-Allow \
  --name Allow-Bing \
  --protocols Http=80 Https=443 \
  --target-fqdns www.bing.com \
  --source-addresses 10.0.2.0/24 \
  --priority 100 \
  --action Allow

# Network Rule: Allow DNS
az network firewall network-rule create \
  --resource-group AZ500LAB09 \
  --firewall-name AzureFirewall \
  --collection-name NetRules-Allow \
  --name Allow-DNS \
  --protocols UDP \
  --destination-ports 53 \
  --destination-addresses 8.8.8.8 8.8.4.4 \
  --source-addresses 10.0.2.0/24 \
  --priority 200 \
  --action Allow
```

## Validation Tests

### Test 1: Access to Bing (Should Succeed)
```bash
# From Srv-Work VM
curl https://www.bing.com
```
**Expected Result**: ✅ HTTP 200 OK

**Why**: Application Rule explicitly allows www.bing.com

### Test 2: Access to Microsoft.com (Should Fail)
```bash
# From Srv-Work VM
curl http://www.microsoft.com
```
**Expected Result**: ❌ Connection timeout or "Action: Deny. No rule matched"

**Why**: No Application Rule for microsoft.com → Implicit Deny

### Test 3: DNS Resolution (Should Succeed)
```bash
# From Srv-Work VM
nslookup www.bing.com 8.8.8.8
```
**Expected Result**: ✅ DNS resolution successful

**Why**: Network Rule allows UDP port 53 to 8.8.8.8

## Traffic Flow Explanation

### Allowed Flow (Bing.com)
```
Srv-Work (10.0.2.10) → Initiates HTTPS to www.bing.com
  ↓
Route Table evaluates: 0.0.0.0/0 → Next Hop: Firewall (10.0.1.4)
  ↓
Azure Firewall receives traffic on private IP
  ↓
Application Rule Collection (Priority 100) evaluates:
  - Source: 10.0.2.10 ✅ (matches 10.0.2.0/24)
  - FQDN: www.bing.com ✅ (matches target)
  - Protocol: HTTPS ✅ (port 443 allowed)
  → Action: ALLOW
  ↓
Firewall performs SNAT (source NAT) with Firewall public IP
  ↓
Traffic egresses to Internet → www.bing.com
  ↓
Response returns via same path (stateful firewall)
  ↓
Srv-Work receives response ✅
```

### Denied Flow (Microsoft.com)
```
Srv-Work (10.0.2.10) → Initiates HTTP to www.microsoft.com
  ↓
Route Table forces traffic to Firewall (10.0.1.4)
  ↓
Azure Firewall evaluates all rules:
  - Application Rules: No match for microsoft.com
  - Network Rules: No match for microsoft.com
  → Default Action: DENY (implicit deny)
  ↓
Firewall drops packet and logs event
  ↓
Srv-Work receives timeout ❌
```

## Key Learnings

### 1. Forced Routing via UDR
- **UDR overrides default Azure routing**
- Next hop = VirtualAppliance forces traffic inspection
- Impossible for VMs to bypass firewall (no alternative route)

### 2. Layer 7 vs Layer 3/4 Filtering
- **Application Rules (L7)**: Filter by FQDN, URL, HTTP headers
- **Network Rules (L3/4)**: Filter by IP, port, protocol
- Application Rules processed **before** Network Rules

### 3. Implicit Deny Model
- Azure Firewall denies everything by default
- Only explicitly allowed traffic passes
- Best practice for security (whitelist approach)

### 4. Hub-and-Spoke Topology
- Centralized security enforcement
- Shared services (Firewall, DNS) in hub
- Workloads isolated in spokes
- Scalable architecture for enterprise

## Security Benefits

✅ **Centralized Control**: Single point for all egress traffic  
✅ **Deep Packet Inspection**: Layer 7 visibility (FQDN, URLs)  
✅ **Threat Intelligence**: Integration with Microsoft threat feeds  
✅ **Audit Trail**: All traffic logged for compliance  
✅ **No Bypass**: UDR prevents direct Internet access  
✅ **IDPS (Intrusion Detection/Prevention)**: Built-in protection  

## Monitoring & Logging

### Enable Diagnostic Logs
```bash
# Create Log Analytics Workspace
az monitor log-analytics workspace create \
  --resource-group AZ500LAB09 \
  --workspace-name AzFW-Logs

# Configure Firewall Diagnostics
az monitor diagnostic-settings create \
  --name AzFW-Diagnostics \
  --resource [firewall-resource-id] \
  --workspace AzFW-Logs \
  --logs '[{"category": "AzureFirewallApplicationRule", "enabled": true}]'
```

### Query Logs
```kusto
AzureDiagnostics
| where Category == "AzureFirewallApplicationRule"
| where TimeGenerated > ago(1h)
| project TimeGenerated, msg_s, Action
| order by TimeGenerated desc
```

## Cost Optimization

- **Firewall**: ~$1.25/hour (~$900/month)
- **Data processed**: ~$0.016/GB
- **Public IP**: ~$3.50/month

**Lab Cost**: ~$30 for 24 hours (delete resources after testing!)

## Skills Demonstrated

`Azure Firewall` `User-Defined Routes` `Application Rules` `Network Rules` `Hub-and-Spoke Architecture` `Layer 7 Filtering` `Forced Tunneling` `Centralized Security`

---

*Part of AZ-500 certification preparation - Secure Networking module*
