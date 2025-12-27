# Lab 06 - Cleanup Resources

Write-Host "Deleting Resource Group: AZ500LAB12" -ForegroundColor Yellow
Write-Host "This will remove all lab resources..." -ForegroundColor Yellow

Remove-AzResourceGroup -Name "AZ500LAB12" -Force -AsJob

Write-Host "`nCleanup job started (running in background)" -ForegroundColor Green
Write-Host "Check status with: Get-Job" -ForegroundColor Cyan
