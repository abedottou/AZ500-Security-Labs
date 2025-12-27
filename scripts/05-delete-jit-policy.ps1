# Lab 11 - Task 7: Delete JIT Policy (triggers Sentinel alert)

$rgName = "AZ500LAB131415"
$location = "eastus"

Write-Host "==================================================" -ForegroundColor Yellow
Write-Host "Lab 11: Delete JIT Policy (Test Alert)" -ForegroundColor Yellow
Write-Host "==================================================" -ForegroundColor Yellow

Write-Host "`nThis will delete the JIT policy to trigger Sentinel alert" -ForegroundColor Cyan
Write-Host "Expected workflow:" -ForegroundColor White
Write-Host "1. JIT policy deleted" -ForegroundColor White
Write-Host "2. Azure Activity Log records event" -ForegroundColor White
Write-Host "3. Sentinel analytics rule detects deletion (5 min)" -ForegroundColor White
Write-Host "4. Alert created (Medium severity)" -ForegroundColor White
Write-Host "5. Incident created" -ForegroundColor White
Write-Host "6. Automation rule triggers playbook" -ForegroundColor White
Write-Host "7. Playbook changes severity: Medium → High" -ForegroundColor White

$confirm = Read-Host "`nContinue with JIT policy deletion? (yes/no)"

if ($confirm -ne "yes") {
    Write-Host "Operation cancelled" -ForegroundColor Red
    exit
}

Write-Host "`nDeleting JIT policy..." -ForegroundColor Cyan

try {
    Remove-AzJitNetworkAccessPolicy `
        -ResourceGroupName $rgName `
        -Location $location `
        -Name "default" `
        -ErrorAction Stop
    
    Write-Host "✅ JIT policy deleted successfully" -ForegroundColor Green
} catch {
    Write-Host "Note: JIT policy may already be deleted or not exist" -ForegroundColor Yellow
}

Write-Host "`n==================================================" -ForegroundColor Cyan
Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "1. Wait 5-10 minutes for alert processing" -ForegroundColor White
Write-Host "2. Portal → Sentinel → Incidents" -ForegroundColor White
Write-Host "3. Look for: 'Playbook Demo' incident" -ForegroundColor White
Write-Host "4. Verify severity: High (changed from Medium)" -ForegroundColor White
Write-Host "5. Check: Logic App run history (Change-Incident-Severity)" -ForegroundColor White
