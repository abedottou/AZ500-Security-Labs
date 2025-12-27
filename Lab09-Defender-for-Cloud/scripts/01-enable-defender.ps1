# Lab 09 - Enable Microsoft Defender for Servers Plan 2

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "Lab 09: Enable Defender for Servers Plan 2" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan

# Get current subscription context
$context = Get-AzContext
$subscriptionId = $context.Subscription.Id
$subscriptionName = $context.Subscription.Name

Write-Host "`nCurrent Subscription:" -ForegroundColor Yellow
Write-Host "Name: $subscriptionName" -ForegroundColor White
Write-Host "ID: $subscriptionId" -ForegroundColor White

# Check current Defender for Servers status
Write-Host "`nChecking current Defender for Servers status..." -ForegroundColor Cyan

$currentPricing = Get-AzSecurityPricing -Name "VirtualMachines"

Write-Host "Current Status:" -ForegroundColor Yellow
Write-Host "  Pricing Tier: $($currentPricing.PricingTier)" -ForegroundColor White
Write-Host "  Sub Plan: $($currentPricing.SubPlan)" -ForegroundColor White

# Enable Defender for Servers Plan 2
Write-Host "`nEnabling Defender for Servers Plan 2..." -ForegroundColor Cyan

Set-AzSecurityPricing `
    -Name "VirtualMachines" `
    -PricingTier "Standard" `
    -SubPlan "P2"

Write-Host "✅ Defender for Servers Plan 2 enabled successfully" -ForegroundColor Green

# Verify
$updatedPricing = Get-AzSecurityPricing -Name "VirtualMachines"

Write-Host "`nUpdated Status:" -ForegroundColor Yellow
Write-Host "  Pricing Tier: $($updatedPricing.PricingTier)" -ForegroundColor White
Write-Host "  Sub Plan: $($updatedPricing.SubPlan)" -ForegroundColor White

# Display features unlocked
Write-Host "`n==================================================" -ForegroundColor Cyan
Write-Host "Features Unlocked by Plan 2:" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "✅ Just-in-Time (JIT) VM Access" -ForegroundColor Green
Write-Host "✅ File Integrity Monitoring (FIM)" -ForegroundColor Green
Write-Host "✅ Adaptive Application Controls" -ForegroundColor Green
Write-Host "✅ Vulnerability Assessment (Qualys)" -ForegroundColor Green
Write-Host "✅ Agentless Scanning" -ForegroundColor Green
Write-Host "✅ Adaptive Network Hardening" -ForegroundColor Green
Write-Host "✅ Microsoft Defender for Endpoint" -ForegroundColor Green

Write-Host "`n==================================================" -ForegroundColor Cyan
Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "1. Portal → Defender for Cloud → Recommendations" -ForegroundColor White
Write-Host "   (Recommendations may take 10-15 minutes to appear)" -ForegroundColor White
Write-Host ""
Write-Host "2. Portal → Defender for Cloud → Security alerts" -ForegroundColor White
Write-Host "   (Monitoring active, alerts appear when threats detected)" -ForegroundColor White
Write-Host ""
Write-Host "3. If VMs exist: Check JIT access availability" -ForegroundColor White
Write-Host "   Portal → VM → Configuration → Just-in-time VM access" -ForegroundColor White
Write-Host ""
Write-Host "💰 Cost: ~$15/server/month (30-day free trial may apply)" -ForegroundColor Yellow
Write-Host ""
