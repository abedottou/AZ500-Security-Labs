# Lab 10 - Enable Just-in-Time VM Access

$rgName = "AZ500LAB131415"
$vmName = "myVM"
$location = "eastus"

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "Lab 10: Enable Just-in-Time VM Access" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan

# Get VM
Write-Host "`nGetting VM details..." -ForegroundColor Cyan
$vm = Get-AzVM -ResourceGroupName $rgName -Name $vmName

if (-not $vm) {
    Write-Error "VM not found. Ensure Lab 09 is completed."
    exit
}

Write-Host "VM found: $vmName" -ForegroundColor Green

# Define JIT policy
Write-Host "`nConfiguring JIT policy..." -ForegroundColor Cyan

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
Write-Host "Enabling JIT VM Access..." -ForegroundColor Cyan

Set-AzJitNetworkAccessPolicy `
    -ResourceGroupName $rgName `
    -Location $location `
    -Name "default" `
    -VirtualMachine $jitPolicyArr `
    -Kind "Basic"

Write-Host "✅ JIT VM Access enabled successfully" -ForegroundColor Green

# Display configuration
Write-Host "`n==================================================" -ForegroundColor Cyan
Write-Host "JIT Configuration:" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "Port: 3389 (RDP)" -ForegroundColor White
Write-Host "Protocol: TCP" -ForegroundColor White
Write-Host "Max duration: 3 hours" -ForegroundColor White
Write-Host "Allowed sources: Any (0.0.0.0/0)" -ForegroundColor White

Write-Host "`n==================================================" -ForegroundColor Cyan
Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "1. Portal → VM → Connect → Request access" -ForegroundColor White
Write-Host "2. Specify source IP (My IP recommended)" -ForegroundColor White
Write-Host "3. Request approved instantly (auto-approval)" -ForegroundColor White
Write-Host "4. RDP connection allowed for 3 hours" -ForegroundColor White
Write-Host "5. Rule auto-deleted after expiration" -ForegroundColor White
