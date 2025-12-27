# Lab 08 - Cleanup Resources

Write-Host "Deleting Resource Group: AZ500LAB131415" -ForegroundColor Yellow
Write-Host "This will remove: VM, Log Analytics Workspace, DCR, all resources" -ForegroundColor Yellow

Remove-AzResourceGroup -Name "AZ500LAB131415" -Force -AsJob

Write-Host "`nCleanup job started (running in background)" -ForegroundColor Green
Write-Host "Check status with: Get-Job" -ForegroundColor Cyan
```

---

## 🎨 **Prompt Nano Banana - Lab 08**
```
Azure Monitor architecture diagram:

LEFT - Azure VM "myVM" (Windows Server 2022):
  - Icon: server/VM
  - Azure Monitor Agent (AMA) installed

CENTER - Data Collection Rule "DCR1":
  - Icon: rule/config document
  - Data sources: Performance Counters (60s interval)
  - Collects: CPU, Memory, Disk, Network metrics

RIGHT - Log Analytics Workspace "LAW57780574":
  - Icon: database/logs
  - KQL queries interface
  - 31-day retention

ARROW FLOW:
myVM → AMA collects metrics → DCR1 processes → LAW stores data

CALLOUT:
"AMA replaces legacy MMA agent. DCR enables centralized config. Sample rate: 60 seconds."

Style: Azure blue, simple, clear data flow
Title: "Lab 08: Log Analytics + Data Collection Rules"
