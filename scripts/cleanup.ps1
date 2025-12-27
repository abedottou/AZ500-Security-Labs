# Lab 11 - Cleanup

Write-Host "==================================================" -ForegroundColor Yellow
Write-Host "Lab 11: Cleanup Sentinel Resources" -ForegroundColor Yellow
Write-Host "==================================================" -ForegroundColor Yellow

$rgName = "AZ500LAB131415"

Write-Host "`nThis will delete:" -ForegroundColor Yellow
Write-Host "- Microsoft Sentinel workspace" -ForegroundColor White
Write-Host "- Analytics rules" -ForegroundColor White
Write-Host "- Playbooks (Logic Apps)" -ForegroundColor White
Write-Host "- API connections" -ForegroundColor White
Write-Host "- Log Analytics Workspace (optional)" -ForegroundColor White

$confirm = Read-Host "`nDelete entire resource group? (yes/no)"

if ($confirm -ne "yes") {
    Write-Host "Cleanup cancelled" -ForegroundColor Red
    exit
}

Write-Host "`nDeleting resource group..." -ForegroundColor Cyan
Remove-AzResourceGroup -Name $rgName -Force -AsJob

Write-Host "✅ Cleanup job started (running in background)" -ForegroundColor Green
Write-Host "Check progress: Get-Job" -ForegroundColor Cyan
```

---

## 🎨 **Prompt Nano Banana - Lab 11**
```
Microsoft Sentinel SIEM+SOAR workflow:

LEFT: Data Sources
- Azure Activity Log (connector)
- Shows: JIT policy deletion event

CENTER: Microsoft Sentinel (on Log Analytics)
- Analytics Rule: "Playbook Demo"
  * KQL query detects JIT deletion
  * Runs every 5 minutes
  * Creates alert (Medium severity)

- Incident created from alert
  * Initially: Medium severity
  * Status: New

RIGHT: Automated Response
- Automation Rule triggers on alert
- Playbook: "Change-Incident-Severity" (Logic App)
  * Action: Update incident severity
  * Medium → High

WORKFLOW (numbered steps):
1. User deletes JIT policy → Activity logged
2. Analytics rule detects (5 min)
3. Alert created (Medium)
4. Incident created
5. Automation rule fires
6. Playbook runs
7. Severity changed to High ✅

CALLOUT:
"Sentinel = SIEM (detect) + SOAR (respond). Playbooks automate response to security incidents."

Style: Purple for Sentinel, blue data flow, green success
Title: "Lab 11: Sentinel SIEM + SOAR Workflow"
