# Lab 06 - Task 1: Create Virtual Network

$rgName = "AZ500LAB12"
$location = "eastus"
$vnetName = "myVirtualNetwork"

Write-Host "Creating Resource Group: $rgName" -ForegroundColor Cyan
New-AzResourceGroup -Name $rgName -Location $location

Write-Host "Creating Virtual Network with Public subnet..." -ForegroundColor Cyan
$publicSubnet = New-AzVirtualNetworkSubnetConfig `
    -Name "Public" `
    -AddressPrefix "10.0.0.0/24"

New-AzVirtualNetwork `
    -ResourceGroupName $rgName `
    -Location $location `
    -Name $vnetName `
    -AddressPrefix "10.0.0.0/16" `
    -Subnet $publicSubnet

Write-Host "VNet created successfully" -ForegroundColor Green
