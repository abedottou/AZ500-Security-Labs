# Lab 10 - Request JIT Access

$rgName = "AZ500LAB131415"
$vmName = "myVM"
$location = "eastus"

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "Lab 10: Request JIT Access" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan

# Get VM
$vm = Get-AzVM -ResourceGroupName $rgName -Name $vmName

# Get your public IP
Write-Host "`nDetecting your public IP..." -ForegroundColor Cyan
$myIp = (Invoke-WebRequest -Uri "https://ifconfig.me/ip").Content.Trim()
Write-Host "Your IP: $myIp" -ForegroundColor Yellow

# Define JIT access request
Write-Host "`nRequesting JIT access..." -ForegroundColor Cyan

$jitPolicyVm = (@{
    id = $vm.Id
    ports = (@{
        number = 3389
        endTimeUtc = (Get-Date).AddHours(3).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
        allowedSourceAddressPrefix = @($myIp)
    })
})

# Request access
Start-AzJitNetworkAccessPolicy `
    -ResourceGroupName $rgName `
    -Location $location `
    -Name "default" `
    -VirtualMachine @($jitPolicyVm)

Write-Host "✅ JIT access request approved" -ForegroundColor Green

# Get VM public IP for RDP
$publicIp = (Get-AzPublicIpAddress -ResourceGroupName $rgName | Where-Object { $_.Name -like "$vmName*" }).IpAddress

Write-Host "`n==================================================" -ForegroundColor Cyan
Write-Host "Access Details:" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "VM Public IP: $publicIp" -ForegroundColor White
Write-Host "Port: 3389 (RDP)" -ForegroundColor White
Write-Host "Allowed from: $myIp" -ForegroundColor White
Write-Host "Duration: 3 hours" -ForegroundColor White
Write-Host "Expires at: $((Get-Date).AddHours(3).ToString('yyyy-MM-dd HH:mm:ss'))" -ForegroundColor White

Write-Host "`n==================================================" -ForegroundColor Cyan
Write-Host "Connect Now:" -ForegroundColor Yellow
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "mstsc /v:$publicIp" -ForegroundColor White
Write-Host "`nUsername: Student" -ForegroundColor White
Write-Host "Password: [Your VM password]" -ForegroundColor White
