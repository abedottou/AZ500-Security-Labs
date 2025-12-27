# Lab 09: Microsoft Defender for Cloud - Enhanced Security for Servers

## 🎯 Objective

Enable and configure **Microsoft Defender for Servers Plan 2** to provide advanced threat protection, vulnerability assessment, and security recommendations for Azure VMs.

## 🏗️ Architecture

![Architecture](./defender-for-cloud-architecture.png)

**Components:**
- Azure Subscription (protected scope)
- Microsoft Defender for Cloud
- Defender for Servers Plan 2
- Azure VMs (protected workloads)

**Capabilities Unlocked:**
- ✅ Just-in-Time (JIT) VM Access
- ✅ File Integrity Monitoring (FIM)
- ✅ Adaptive Application Controls
- ✅ Vulnerability Assessment (Qualys scanner)
- ✅ Agentless scanning
- ✅ Adaptive Network Hardening
- ✅ Microsoft Defender for Endpoint integration

---

## 📋 Lab Task

### Task 1: Enable Microsoft Defender for Servers Plan 2

**Portal Steps:**
```
1. Portal → Search "Microsoft Defender for Cloud"

2. Left menu → Management → Environment settings

3. Expand subscription tree → Select your subscription

4. Defender plans blade

5. Locate "Servers" row:
   - Current status: Off
   - Click toggle to: On
   - Select: Plan 2 (Full capabilities)

6. Click Save (top of page)

7. Wait for notification: "Defender plans updated successfully"
```

**PowerShell:**
```powershell
# See scripts/01-enable-defender.ps1

# Get subscription context
$subscriptionId = (Get-AzContext).Subscription.Id

# Enable Defender for Servers Plan 2
Set-AzSecurityPricing `
    -Name "VirtualMachines" `
    -PricingTier "Standard" `
    -SubPlan "P2"

Write-Host "Defender for Servers Plan 2 enabled" -ForegroundColor Green
```

**Verification:**
```
1. Defender for Cloud → Environment settings → [Subscription]

2. Verify "Servers" shows:
   - Status: On
   - Plan: Plan 2

3. Features available (listed below):
   ✅ Just-in-Time VM access
   ✅ File Integrity Monitoring
   ✅ Adaptive Application Controls
   ✅ Vulnerability Assessment
   ✅ Agentless scanning
   ✅ Adaptive Network Hardening
   ✅ Microsoft Defender for Endpoint
```

---

## ✅ Validation

**Expected Results:**

1. **Defender for Servers enabled:**
   - Portal → Defender for Cloud → Environment settings → Subscription
   - Servers row shows: On (Plan 2)

2. **Recommendations appear** (within 24 hours):
   - Portal → Defender for Cloud → Recommendations
   - Filter: Resource type = Virtual machines
   - Examples:
     * Enable Just-in-Time network access control
     * Install endpoint protection solution on VMs
     * Apply system updates on your machines
     * Remediate vulnerabilities found on VMs

3. **Security alerts enabled:**
   - Portal → Defender for Cloud → Security alerts
   - Ready to detect threats (no alerts = good sign if no threats)

4. **JIT access available** (if VMs exist):
   - Portal → Virtual machines → [VM] → Configuration
   - "Just-in-time VM access" option appears

---

## 🔐 Features Unlocked by Plan 2

### 1. Just-in-Time (JIT) VM Access
```
Function: Reduces attack surface by blocking RDP/SSH by default
Mechanism: Temporary NSG rules (user-requested)
Benefit: 96% reduction in brute force attempts
```

### 2. File Integrity Monitoring (FIM)
```
Function: Tracks changes to critical files and registry
Monitored: System files, application files, registry keys
Alert: Unauthorized modifications detected
```

### 3. Adaptive Application Controls
```
Function: Allowlist approved applications
Mechanism: Machine learning baseline
Benefit: Block unauthorized executables
```

### 4. Vulnerability Assessment
```
Scanner: Qualys (built-in, no extra license)
Frequency: Daily scans
Detection: OS vulnerabilities, missing patches
Remediation: Automated recommendations
```

### 5. Agentless Scanning
```
Function: VM disk snapshot analysis (no agent needed)
Scope: Vulnerabilities, malware, secrets in code
Frequency: Weekly (configurable)
```

### 6. Adaptive Network Hardening
```
Function: NSG rule optimization recommendations
Analysis: Traffic patterns + threat intelligence
Benefit: Tighten network security automatically
```

### 7. Microsoft Defender for Endpoint Integration
```
Function: Advanced endpoint detection and response (EDR)
Deployment: Automatic (if VMs eligible)
Capabilities: Behavioral analysis, threat hunting
```

---

## 💰 Pricing

**Defender for Servers Plan 2:**
- **Cost**: ~$15/server/month
- **Free tier available**: First 30 days (trial)
- **Billing**: Per protected server (VM/Arc server)

**What's included:**
- All 7 features above
- 24/7 threat detection
- Security recommendations
- Compliance dashboard
- Integration with Sentinel

**Plan 1 vs Plan 2:**

| Feature | Plan 1 | Plan 2 |
|---------|--------|--------|
| Price | ~$5/server/month | ~$15/server/month |
| JIT VM Access | ✅ | ✅ |
| File Integrity Monitoring | ❌ | ✅ |
| Adaptive Application Controls | ❌ | ✅ |
| Vulnerability Assessment | ❌ | ✅ |
| Agentless Scanning | ❌ | ✅ |
| Defender for Endpoint | ❌ | ✅ |

**Lab 09 uses Plan 2** (full capabilities)

---

## 🎓 Key Concepts

### Cloud Workload Protection (CWP)

**Defender for Cloud protects:**
- ✅ Servers (VMs, Arc-enabled servers)
- ✅ App Services
- ✅ SQL Databases
- ✅ Storage Accounts
- ✅ Kubernetes (AKS)
- ✅ Container Registries
- ✅ Key Vaults

**Each workload type has a dedicated Defender plan**

Lab 09 focuses on **Servers only**

---

### Free Tier vs Paid Plans

**Free Tier (Default):**
- Secure Score
- Basic recommendations
- Compliance dashboard
- No advanced threat protection

**Paid Plans (Defender plans):**
- Advanced threat detection
- Vulnerability scanning
- JIT access
- File Integrity Monitoring
- Behavioral analytics

**Lab 09 enables paid plan for Servers**

---

### Defender for Cloud vs Defender for Endpoint

| Aspect | Defender for Cloud | Defender for Endpoint |
|--------|-------------------|----------------------|
| **Scope** | Azure resources (VMs, PaaS) | Endpoints (Windows, Linux, Mac, Mobile) |
| **Focus** | Cloud security posture | Endpoint detection and response (EDR) |
| **Deployment** | Azure subscription level | Device level |
| **Integration** | Defender for Servers includes Defender for Endpoint | Can be standalone (Microsoft 365 E5) |

**In Lab 09:** Enabling Defender for Servers Plan 2 automatically includes Defender for Endpoint integration

---

## 🛠️ Skills Demonstrated

- Microsoft Defender for Cloud navigation
- Enabling Defender plans at subscription level
- Understanding Cloud Workload Protection (CWP)
- Server security posture management
- Threat protection configuration
- Azure security feature comparison

---

## 🎯 MITRE ATT&CK Mapping

### Techniques Detected/Mitigated:

**T1190 - Exploit Public-Facing Application**
- Detection: Vulnerability Assessment finds exploitable CVEs
- Mitigation: Patch recommendations

**T1068 - Exploitation for Privilege Escalation**
- Detection: Behavioral analytics (Defender for Endpoint)
- Alert: Suspicious privilege escalation detected

**T1078 - Valid Accounts**
- Mitigation: JIT VM Access (blocks brute force)
- Detection: Failed login attempts monitored

**T1486 - Data Encrypted for Impact (Ransomware)**
- Detection: File Integrity Monitoring alerts on mass encryption
- Response: Defender for Endpoint automated response

**T1105 - Ingress Tool Transfer**
- Detection: Adaptive Application Controls block unauthorized executables
- Alert: Unapproved tool execution detected

---

## 🧹 Cleanup

**Disable Defender for Servers:**
```powershell
# See scripts/cleanup.ps1

Set-AzSecurityPricing `
    -Name "VirtualMachines" `
    -PricingTier "Free"

Write-Host "Defender for Servers disabled (reverted to Free tier)" -ForegroundColor Yellow
```

**Note:** Disabling returns to Free tier. No resources deleted. Recommendations remain visible but advanced features disabled.

---

## 📝 Notes

### Important Points:

**Automatic Agent Deployment:**
- Defender for Cloud can auto-install agents (Log Analytics Agent on legacy, AMA on new VMs)
- Configure: Environment settings → Auto provisioning

**Recommendation Delay:**
- Initial recommendations may take 10-15 minutes to appear
- Full assessment: 24 hours for comprehensive recommendations

**Cost Awareness:**
- Enabling Defender plans starts billing immediately
- Free trial: 30 days (if eligible)
- Disable when lab complete to avoid charges

**Scope:**
- Defender plans apply to entire subscription
- Cannot enable per-VM (subscription-level only)
- Use Azure Policy to exclude specific VMs if needed

**Integration with Lab 08:**
- Defender for Cloud can leverage Log Analytics Workspace from Lab 08
- Security events can be sent to same workspace
- KQL queries work across Defender data + performance data

---

## 🔗 Related Labs

**Lab 08 (Log Analytics + DCR):**
- Provides workspace for Defender logs
- Performance data + Security data = complete visibility

**Lab 10 (JIT VM Access):**
- Uses JIT feature enabled in Lab 09
- Demonstrates practical attack surface reduction

**Lab 11 (Sentinel):**
- Ingests Defender for Cloud alerts
- Automated response to security threats

---

**Lab completed when:**
- Defender for Servers Plan 2 enabled ✅
- Status shows "On" in Environment settings ✅
- Features like JIT available (if VMs exist) ✅
- Recommendations start appearing (within 24h) ✅
