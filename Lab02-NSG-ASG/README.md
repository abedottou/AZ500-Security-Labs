# Lab 02: Network Security Groups & Application Security Groups

## Objective
Implement scalable network filtering using Application Security Groups (ASG) that filter traffic based on server roles rather than static IP addresses.

## Architecture

![NSG-ASG Architecture](./nsg-asg-architecture.png)

**Network Components:**
- Virtual Network: myVNet (10.0.0.0/16)
- Subnet: default (10.0.0.0/24)
- Network Security Group: myNsg (attached to subnet)
- Application Security Groups:
  - myAsgWebServers (web tier)
  - myAsgMgmtServers (management tier)
- Virtual Machines:
  - myVMWeb (associated with myAsgWebServers)
  - myVMMgmt (associated with myAsgMgmtServers)

## NSG Rules Configuration

| Priority | Name | Source | Destination | Ports | Protocol | Action |
|----------|------|--------|-------------|-------|----------|--------|
| 100 | Allow-Web-Traffic | Any | myAsgWebServers | 80, 443 | TCP | Allow |
| 110 | Allow-RDP-Mgmt | Any | myAsgMgmtServers | 3389 | TCP | Allow |

**Default Rules:**
- 65000: AllowVNetInbound (allows intra-VNet traffic)
- 65500: DenyAllInbound (implicit deny - catch all)

## Implementation Details

### NSG Association
The Network Security Group is associated at the **subnet level** (not NIC level) for centralized management:
```bash
# NSG is attached to the entire subnet
# All VMs in the subnet inherit subnet-level NSG rules
```

### ASG Assignment
Each VM's Network Interface is tagged with its corresponding ASG:
```bash
# myVMWeb NIC → myAsgWebServers
# myVMMgmt NIC → myAsgMgmtServers
```

### Traffic Flow Processing
1. Traffic arrives at subnet boundary
2. NSG evaluates rules by priority (100, 110, ...)
3. If rule matches ASG destination, action is applied
4. If no match, default rule 65500 denies traffic

## Key Learnings

**ASG vs IP-based Filtering:**

Traditional NSG approach:
```bash
# Problem: Must update rules when IPs change
Allow TCP 80 to 10.0.0.4
Allow TCP 80 to 10.0.0.5
Allow TCP 80 to 10.0.0.6
```

ASG approach:
```bash
# Solution: Filter by role, not IP
Allow TCP 80 to myAsgWebServers
# Add new web servers to ASG → rules apply automatically
```

**Scalability Benefits:**
- Add 10 new web servers → just assign them to myAsgWebServers ASG
- No NSG rule modifications needed
- Centralized policy management

**Processing Order:**
When both subnet-level and NIC-level NSGs exist:
1. Subnet NSG evaluated first
2. Then NIC NSG evaluated
3. Traffic must pass BOTH to be allowed

## Validation Results

### Test 1: Web Access to myVMWeb
```bash
# HTTP/HTTPS to myVMWeb
curl http://<myVMWeb-public-ip>
```
✅ **Result:** Connection successful (Rule 100 matched)

### Test 2: RDP to myVMWeb
```bash
# RDP attempt to web server
mstsc /v:<myVMWeb-public-ip>
```
❌ **Result:** Connection denied (No rule matched → default deny)

### Test 3: RDP to myVMMgmt
```bash
# RDP to management server
mstsc /v:<myVMMgmt-public-ip>
```
✅ **Result:** Connection successful (Rule 110 matched)

### Test 4: Web Access to myVMMgmt
```bash
# HTTP attempt to management server
curl http://<myVMMgmt-public-ip>
```
❌ **Result:** Connection denied (No rule matched → default deny)

## Security Principles Demonstrated

**Tag-Based Security:**
- Security policies follow server roles, not network addresses
- Decouples security from infrastructure changes

**Implicit Deny:**
- Default rule 65500 blocks all unmatched traffic
- Must explicitly allow required traffic

**Centralized Management:**
- Single NSG controls entire subnet
- ASGs provide granular per-server-role filtering

**Defense in Depth:**
- Network layer filtering (NSG)
- Application layer filtering (can be added later)

## Best Practices Applied

✅ **NSG at subnet level** (easier management than per-NIC)  
✅ **ASG for role-based grouping** (scalable)  
✅ **Explicit allow rules only** (implicit deny by default)  
✅ **Lowest necessary priority numbers** (100, 110 vs 1000, 2000)  
✅ **No public RDP exposure** (in production, use Bastion/VPN instead)

## Skills Demonstrated

`Network Security Groups` `Application Security Groups` `Azure Virtual Networks` `Layer 3/4 Filtering` `Tag-Based Security` `Scalable Network Architecture`

---

*Completed as part of AZ-500 certification preparation*
