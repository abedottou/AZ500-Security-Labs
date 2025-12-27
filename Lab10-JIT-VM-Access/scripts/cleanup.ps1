# Lab 10 - Cleanup (Disable JIT)

$rgName = "AZ500LAB131415"
$location = "eastus"

Write-Host "==================================================" -ForegroundColor Yellow
Write-Host "Lab 10: Disable JIT VM Access" -ForegroundColor Yellow
Write-Host "==================================================" -ForegroundColor Yellow

Write-Host "`nThis will remove JIT protection from the VM." -ForegroundColor Yellow
Write-Host "Port 3389 will revert to NSG default rules." -ForegroundColor Yellow

$confirm = Read-Host "`nContinue? (yes/no)"

if ($confirm -ne "yes") {
    Write-Host "Operation cancelled" -ForegroundColor Red
    exit
}

# Remove JIT policy
Write-Host "`nRemoving JIT policy..." -ForegroundColor Cyan

Remove-AzJitNetworkAccessPolicy `
    -ResourceGroupName $rgName `
    -Location $location `
    -Name "default"

Write-Host "✅ JIT VM Access disabled" -ForegroundColor Green
Write-Host "`nLab 10 cleanup complete" -ForegroundColor Green
```

---

## 🎨 **Prompt Nano Banana - Lab 10**
```
JIT VM Access architecture:

LEFT: Azure VM "myVM" with RDP port 3389

CENTER: NSG with 3 states (vertical timeline):

State 1 - Before JIT (top):
  • Port 3389: ❌ BLOCKED (always)
  • Attack surface: 100%

State 2 - JIT Enabled + Access Requested (middle):
  • Priority 10 rule created (temporary)
  • Port 3389: ✅ ALLOWED from user IP
  • Duration: 3 hours
  • Attack surface: 4%

State 3 - After Expiration (bottom):
  • Priority 10 rule deleted (auto)
  • Port 3389: ❌ BLOCKED again
  • Attack surface: 4% (96% reduction)

RIGHT: User requesting access (laptop icon):
  • Request via Portal/PowerShell
  • Specify: IP, duration (max 3h)
  • Auto-approved

ARROW FLOW:
1. User → "Request JIT access"
2. Defender creates NSG rule Priority 10
3. User connects via RDP (3h window)
4. Rule auto-expires → Port blocked

CALLOUT:
"JIT reduces RDP exposure by 96%. Port blocked by default, open only when requested."

Style: Blue NSG, green for allowed, red for blocked, timeline visual
Title: "Lab 10: Just-in-Time VM Access"
