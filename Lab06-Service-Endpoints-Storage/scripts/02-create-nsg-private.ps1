# Lab 06 - Task 3: Configure NSG for Private Subnet

$rgName = "AZ500LAB12"
$nsgName = "myNsgPrivate"

Write-Host "Creating NSG: $nsgName" -ForegroundColor Cyan
$nsg = New-AzNetworkSecurityGroup `
    -ResourceGroupName $rgName `
    -Location "eastus" `
    -Name $nsgName

Write-Host "Adding Allow Storage rule (Priority 1000)..." -ForegroundColor Cyan
$nsg | Add-AzNetworkSecurityRuleConfig `
    -Name "Allow-Storage-All" `
    -Description "Allow outbound to Storage" `
    -Access Allow `
    -Protocol * `
    -Direction Outbound `
    -Priority 1000 `
    -SourceAddressPrefix VirtualNetwork `
    -SourcePortRange * `
    -DestinationAddressPrefix Storage `
    -DestinationPortRange * | Set-AzNetworkSecurityGroup

Write-Host "Adding Deny Internet rule (Priority 1100)..." -ForegroundColor Cyan
$nsg | Add-AzNetworkSecurityRuleConfig `
    -Name "Deny-Internet-All" `
    -Description "Deny outbound to Internet" `
    -Access Deny `
    -Protocol * `
    -Direction Outbound `
    -Priority 1100 `
    -SourceAddressPrefix VirtualNetwork `
    -SourcePortRange * `
    -DestinationAddressPrefix Internet `
    -DestinationPortRange * | Set-AzNetworkSecurityGroup

Write-Host "Adding Allow RDP rule (Priority 1200)..." -ForegroundColor Cyan
$nsg | Add-AzNetworkSecurityRuleConfig `
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

Write-Host "Associating NSG with Private subnet..." -ForegroundColor Cyan
$vnet = Get-AzVirtualNetwork -ResourceGroupName $rgName -Name "myVirtualNetwork"
Set-AzVirtualNetworkSubnetConfig `
    -VirtualNetwork $vnet `
    -Name "Private" `
    -AddressPrefix "10.0.1.0/24" `
    -NetworkSecurityGroup $nsg
$vnet | Set-AzVirtualNetwork

Write-Host "NSG configured and associated successfully" -ForegroundColor Green
