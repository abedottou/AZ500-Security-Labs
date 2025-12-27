# Lab 06 - Task 4: Configure NSG for Public Subnet

$rgName = "AZ500LAB12"
$nsgName = "myNsgPublic"

Write-Host "Creating NSG: $nsgName" -ForegroundColor Cyan
$nsgPublic = New-AzNetworkSecurityGroup `
    -ResourceGroupName $rgName `
    -Location "eastus" `
    -Name $nsgName

Write-Host "Adding Allow RDP rule (Priority 1200)..." -ForegroundColor Cyan
$nsgPublic | Add-AzNetworkSecurityRuleConfig `
    -Name "Allow-RDP-All" `
    -Description "Allow inbound RDP" `
    -Access Allow `
    -Protocol Tcp `
    -Direction Inbound `
    -Priority 1200 `
    -SourceAddressPrefix * `
    -SourcePortRange * `
    -DestinationAddressPrefix VirtualNetwork `
    -DestinationPortRange 3389 | Set-AzNetworkSecurityGroup

Write-Host "Associating NSG with Public subnet..." -ForegroundColor Cyan
$vnet = Get-AzVirtualNetwork -ResourceGroupName $rgName -Name "myVirtualNetwork"
Set-AzVirtualNetworkSubnetConfig `
    -VirtualNetwork $vnet `
    -Name "Public" `
    -AddressPrefix "10.0.0.0/24" `
    -NetworkSecurityGroup $nsgPublic
$vnet | Set-AzVirtualNetwork

Write-Host "NSG configured and associated successfully" -ForegroundColor Green
