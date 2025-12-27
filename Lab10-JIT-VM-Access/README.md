# Lab 10: Just-in-Time (JIT) VM Access

## 🎯 Objective

Configure **Just-in-Time (JIT) VM Access** to reduce attack surface by blocking management ports (RDP/SSH) by default and allowing temporary access only when needed.

## 🏗️ Architecture

![Architecture](./jit-vm-access-architecture.png)

**Components:**
- Azure VM: myVM (from Lab 09)
- Microsoft Defender for Cloud (with Servers Plan 2 enabled)
- Just-in-Time VM Access policy
- NSG with dynamic rules

**Access Model:**
```
Default: RDP port 3389 BLOCKED
↓
User requests JIT access (specify duration + source IP)
↓
Defender creates temporary NSG rule (Priority 10)
↓
RDP access ALLOWED for specified duration
↓
Rule auto-deleted after expiration
↓
RDP port 3389 BLOCKED again
```

**Attack Surface Reduction: 96%**

---

## 📋 Prerequisites

- **Lab 09 completed:** Defender for Servers Plan 2 must be enabled
- Azure VM with public IP
- RDP/SSH port initially open (default NSG rule)

---

## 🔧 Lab Tasks

### Task 1: Enable JIT VM Access

**Portal Steps:**
```
1. Portal → Virtual machines → Select your VM (e.g., myVM)

2. Left menu → Configuration

3. Locate section: "Just-in-time VM access"

4. Click "Enable just-in-time"

5. JIT configuration blade opens:
   
   Default settings (pre-configured):
   - Port: 3389 (RDP for Windows) or 22 (SSH for Linux)
   - Protocol: TCP
   - Allowed source IPs: Any (can be restricted)
   - Max request time: 3 hours
   
6. Review settings (keep defaults for lab)

7. Click "Save"

8. Wait for notification: "Just-in-time access enabled successfully"
```

**PowerShell:**
```powershell
# See scripts/01-enable-jit.ps1

$rgName = "AZ500LAB131415"  # Or your RG from Lab 09
$vmName = "myVM"
$location = "eastus"

# Get VM details
$vm = Get-AzVM -ResourceGroupName $rgName -Name $vmName

# Define JIT policy
$jitPolicy = (@{
    id = $vm.Id
    ports = (@{
        number = 3389
        protocol = "TCP"
        allowedSourceAddressPrefix = @("*")
        maxRequestAccessDuration = "PT3H"
    })
})

$jitPolicyArr = @($jitPolicy)

# Enable JIT
Set-AzJitNetworkAccessPolicy `
    -ResourceGroupName $rgName `
    -Location $location `
    -Name "default" `
    -VirtualMachine $jitPolicyArr `
    -Kind "Basic"
```

**Verification:**
```
1. Portal → VM → Configuration
2. "Just-in-time VM access" section shows: "Enabled"
3. Button available: "Request access"
```

---

### Task 2: Request JIT Access

**Portal Steps:**
```
1. Portal → Virtual machines → myVM

2. Click "Connect" (top menu)

3. Drop-down menu → Select "Connect"
   (Or: Configuration → Just-in-time VM access → Request access)

4. Request access blade:
   
   Configuration:
   - My IP: [Auto-detected] (e.g., 203.0.113.45)
     OR
   - IP range: Specify custom CIDR (e.g., 203.0.113.0/24)
   
   - Port: 3389 (pre-selected)
   - Time range: 3 hours (default, max per policy)
   
5. Click "Request access"

6. Wait for approval (auto-approved for lab, instant)

7. Notification: "Access request approved"

8. NSG rule created:
   - Priority: 10 (highest, overrides deny rules)
   - Source: Your IP
   - Destination: VM IP
   - Port: 3389
   - Action: Allow
   - Duration: 3 hours
```

**PowerShell:**
```powershell
# Request JIT access
$rgName = "AZ500LAB131415"
$vmName = "myVM"
$location = "eastus"

# Get VM
$vm = Get-AzVM -ResourceGroupName $rgName -Name $vmName

# Get your public IP
$myIp = (Invoke-WebRequest -Uri "https://ifconfig.me/ip").Content.Trim()

# Request access
$jitPolicyVm = (@{
    id = $vm.Id
    ports = (@{
        number = 3389
        endTimeUtc = (Get-Date).AddHours(3).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
        allowedSourceAddressPrefix = @($myIp)
    })
})

Start-AzJitNetworkAccessPolicy `
    -ResourceGroupName $rgName `
    -Location $location `
    -Name "default" `
    -VirtualMachine @($jitPolicyVm)
```

**What Happens Behind the Scenes:**
1. Defender for Cloud receives request
2. Creates NSG inbound rule:
   - Name: `SecurityCenter-JITRule-<timestamp>`
   - Priority: 10
   - Source: Your IP
   - Destination port: 3389
   - Action: Allow
3. Rule becomes effective immediately
4. Auto-deletion scheduled after 3 hours

---

### Task 3: Connect to VM via RDP

**Steps:**
```
1. After JIT access approved:
   - Download RDP file (Connect blade)
   - Or use: mstsc /v:<VM-Public-IP>

2. Connect:
   - Address: <VM-Public-IP>
   - Username: Student (or your admin user)
   - Password: [Your VM password]

3. Result: ✅ Connection successful

4. Work on VM as needed (within 3-hour window)
```

**Verification:**
- RDP connection succeeds (port 3389 temporarily open)
- Check NSG rules:
```
  Portal → VM → Networking → Inbound port rules
  Priority 10 rule visible with your source IP
```

---

### Task 4: Verify Rule Expiration

**After 3 hours:**
```
1. Portal → VM → Networking → Inbound port rules

2. Priority 10 JIT rule: DELETED (auto-removed)

3. Try RDP connection again:
   - Result: ❌ Connection timeout/refused
   
4. Port 3389 blocked again (default state restored)
```

**Check JIT Access History:**
```
1. Portal → Defender for Cloud → Workload protections

2. Just-in-time VM access

3. "Configured" tab → Select VM

4. View access history:
   - User: [Your account]
   - Time: [Request timestamp]
   - Duration: 3 hours
   - Source IP: [Your IP]
   - Status: Expired / Active
```

---

## ✅ Validation

**Expected Results:**

1. **JIT Policy Enabled:**
   - VM → Configuration shows "Enabled"
   - Default settings: Port 3389, Max 3 hours

2. **Access Request Works:**
   - Request submitted successfully
   - Auto-approved (instant)
   - NSG rule Priority 10 created

3. **RDP Connection Succeeds:**
   - During 3-hour window: ✅ Can connect
   - After expiration: ❌ Cannot connect

4. **Rule Auto-Deleted:**
   - After 3 hours: Priority 10 rule removed
   - NSG returns to original state

**Attack Surface Reduction:**
- Before JIT: Port 3389 always open (24/7 exposure)
- After JIT: Port 3389 open only when requested (~4% of time)
- Reduction: **96%** less exposure to brute force attacks

---

## 🔐 Key Concepts

### How JIT Works

**Default State (JIT Enabled):**
```
NSG Inbound Rules:
- Priority 10: [No rule - slot reserved for JIT]
- Priority 1000: Deny RDP from Internet (default)
- Priority 65000: Allow VNet traffic

Result: RDP blocked from Internet ❌
```

**During JIT Access (3-hour window):**
```
NSG Inbound Rules:
- Priority 10: Allow RDP from <Your-IP> ✅ (JIT-created)
- Priority 1000: Deny RDP from Internet
- Priority 65000: Allow VNet traffic

Result: RDP allowed from your IP only ✅
```

**After Expiration:**
```
NSG Inbound Rules:
- Priority 10: [Removed automatically]
- Priority 1000: Deny RDP from Internet ❌
- Priority 65000: Allow VNet traffic

Result: RDP blocked again ❌
```

**Key Point:** Priority 10 (lower number = higher priority) overrides Priority 1000 deny rule.

---

### JIT Policy Parameters

**Configurable Settings:**

1. **Port:**
   - RDP: 3389 (Windows)
   - SSH: 22 (Linux)
   - Custom: Any port (e.g., 5985 for WinRM)

2. **Protocol:**
   - TCP (most common)
   - UDP
   - Any

3. **Allowed Source IPs:**
   - Any (0.0.0.0/0) - default, least secure
   - My IP (auto-detected) - recommended
   - IP Range (CIDR) - for team access
   - Service Tag (not common for JIT)

4. **Max Request Duration:**
   - Default: 3 hours
   - Range: 1 hour to 24 hours
   - Recommendation: Shortest necessary (principle of least privilege)

5. **Request Type:**
   - Per request: Manual approval (not in lab)
   - Auto-approved: Instant (lab default for VM owners)

---

### NSG Rule Priority

**Priority Ranges:**
- 100-4096: Custom rules
- 65000-65500: Default rules (system)

**JIT Uses Priority 10:**
- Ensures JIT rules override any custom deny rules
- Cannot be changed (hardcoded by Defender for Cloud)

**Conflict Resolution:**
- If Priority 10 already used: JIT fails (rare)
- Solution: Remove conflicting rule or use different VM

---

## 🛠️ Skills Demonstrated

- Microsoft Defender for Cloud JIT configuration
- NSG dynamic rule management
- Temporary access provisioning
- Attack surface reduction
- Principle of least privilege (time-based access)
- RDP connection with JIT

---

## 🎯 MITRE ATT&CK Mapping

### Techniques Mitigated:

**T1078 - Valid Accounts (Brute Force)**
- Mitigation: Port 3389 blocked by default
- Attack vector eliminated 96% of the time

**T1133 - External Remote Services**
- Mitigation: Time-limited access (max 3 hours)
- Stolen credentials useless after expiration

**T1021.001 - Remote Desktop Protocol**
- Mitigation: Source IP restriction
- Only authorized IPs can access (blocks bots/scanners)

---

## 🧹 Cleanup

**Disable JIT (Optional):**
```powershell
# See scripts/cleanup.ps1

$rgName = "AZ500LAB131415"
$location = "eastus"

# Remove JIT policy
Remove-AzJitNetworkAccessPolicy `
    -ResourceGroupName $rgName `
    -Location $location `
    -Name "default"
```

**Note:** Disabling JIT does NOT delete the VM. It only removes JIT protection (port becomes always open if NSG allows).

---

## 📝 Notes

### Important Points:

**Requirement:**
- Defender for Servers Plan 2 must be enabled (Lab 09)
- JIT feature NOT available in Free tier or Plan 1

**Access Duration:**
- Cannot exceed max configured in policy (default 3 hours)
- Can request shorter duration (e.g., 1 hour)
- Extension requires new request (no auto-renewal)

**Source IP Considerations:**
- "My IP" is recommended (auto-detected)
- Dynamic IPs change: May need new request if IP changes
- VPN users: Use VPN exit IP, not local IP

**Multiple Ports:**
- Can configure JIT for multiple ports (RDP + SSH)
- Each port = separate rule in policy
- Each request can specify which ports needed

**Integration with RBAC:**
- VM Owner/Contributor: Auto-approved requests
- VM Reader: Requires approval (not in lab)
- Security Admin: Can configure JIT policies

---

**Lab completed when:**
- JIT enabled on VM ✅
- Access requested and approved ✅
- RDP connection successful during window ✅
- Rule auto-deleted after 3 hours ✅
- Attack surface reduced by 96% ✅
