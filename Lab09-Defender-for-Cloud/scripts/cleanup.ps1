# Lab 09 - Cleanup (Disable Defender for Servers)

Write-Host "==================================================" -ForegroundColor Yellow
Write-Host "Lab 09: Disable Defender for Servers" -ForegroundColor Yellow
Write-Host "==================================================" -ForegroundColor Yellow

Write-Host "`nThis will:" -ForegroundColor Yellow
Write-Host "  - Disable Defender for Servers (revert to Free tier)" -ForegroundColor White
Write-Host "  - Stop billing for advanced features" -ForegroundColor White
Write-Host "  - Remove access to Plan 2 capabilities" -ForegroundColor White

$confirm = Read-Host "`nContinue? (yes/no)"

if ($confirm -ne "yes") {
    Write-Host "Operation cancelled" -ForegroundColor Red
    exit
}

# Get current status
Write-Host "`nCurrent Defender for Servers status..." -ForegroundColor Cyan
$currentPricing = Get-AzSecurityPricing -Name "VirtualMachines"
Write-Host "  Pricing Tier: $($currentPricing.PricingTier)" -ForegroundColor White
Write-Host "  Sub Plan: $($currentPricing.SubPlan)" -ForegroundColor White

# Disable (revert to Free tier)
Write-Host "`nDisabling Defender for Servers Plan 2..." -ForegroundColor Cyan

Set-AzSecurityPricing `
    -Name "VirtualMachines" `
    -PricingTier "Free"

Write-Host "✅ Defender for Servers disabled (reverted to Free tier)" -ForegroundColor Green

# Verify
$updatedPricing = Get-AzSecurityPricing -Name "VirtualMachines"

Write-Host "`nUpdated Status:" -ForegroundColor Yellow
Write-Host "  Pricing Tier: $($updatedPricing.PricingTier)" -ForegroundColor White

Write-Host "`n==================================================" -ForegroundColor Cyan
Write-Host "Features Now Disabled:" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "❌ Just-in-Time (JIT) VM Access" -ForegroundColor Red
Write-Host "❌ File Integrity Monitoring (FIM)" -ForegroundColor Red
Write-Host "❌ Adaptive Application Controls" -ForegroundColor Red
Write-Host "❌ Vulnerability Assessment" -ForegroundColor Red
Write-Host "❌ Agentless Scanning" -ForegroundColor Red
Write-Host "❌ Adaptive Network Hardening" -ForegroundColor Red
Write-Host "❌ Microsoft Defender for Endpoint" -ForegroundColor Red

Write-Host "`nFree Tier Still Available:" -ForegroundColor Yellow
Write-Host "✅ Secure Score" -ForegroundColor Green
Write-Host "✅ Basic recommendations" -ForegroundColor Green
Write-Host "✅ Compliance dashboard" -ForegroundColor Green

Write-Host "`nLab 09 cleanup complete" -ForegroundColor Green
```

---

## 🎨 **Prompt Nano Banana - Lab 09**
```
Microsoft Defender for Cloud architecture diagram:

CENTER - Azure Subscription (large container):
  - Label: "Azure Subscription"
  - Inside: Cloud icon with resources (VMs, databases, storage)

TOP - Microsoft Defender for Cloud (shield icon):
  - Label: "Microsoft Defender for Cloud"
  - Status: Enabled
  - Coverage: Subscription-wide

MIDDLE - Defender for Servers Plan 2 (highlighted box):
  - Icon: Server with shield
  - Label: "Defender for Servers - Plan 2"
  - Status: ON
  - Price badge: "$15/server/month"

BOTTOM - 7 Feature boxes (arranged in grid, 3-2-2 layout):

Row 1:
1. JIT VM Access (lock + clock icon)
2. File Integrity Monitoring (file + magnifying glass)
3. Adaptive Application Controls (shield + app)

Row 2:
4. Vulnerability Assessment (bug + scanner)
5. Agentless Scanning (cloud + scan)

Row 3:
6. Adaptive Network Hardening (network + optimization)
7. Defender for Endpoint (endpoint + EDR)

ARROWS:
- Defender for Cloud → Servers Plan 2: "Enable" (green)
- Plan 2 → 7 Features: "Unlocks" (dotted lines to each feature)

BADGE on Plan 2:
"✅ Lab 09: Enabled"
"⏱️ 30-day free trial"

CALLOUT:
"Enabling Plan 2 unlocks all 7 advanced security features for Azure VMs"

Style: Azure blue, shield icons, clean grid layout
Title: "Lab 09: Defender for Servers Plan 2 Activation"
