# Lab 06 - Task 5: Create Storage Account with File Share

$rgName = "AZ500LAB12"
$storageAccountName = "az500lab12st$(Get-Random -Maximum 99999)"

Write-Host "Creating Storage Account: $storageAccountName" -ForegroundColor Cyan
$storageAccount = New-AzStorageAccount `
    -ResourceGroupName $rgName `
    -Name $storageAccountName `
    -Location "eastus" `
    -SkuName Standard_LRS `
    -Kind StorageV2

Write-Host "Creating file share: my-file-share" -ForegroundColor Cyan
$ctx = $storageAccount.Context
New-AzStorageShare -Name "my-file-share" -Context $ctx

Write-Host "Enabling Service Endpoint on Private subnet..." -ForegroundColor Cyan
$vnet = Get-AzVirtualNetwork -ResourceGroupName $rgName -Name "myVirtualNetwork"
$nsg = Get-AzNetworkSecurityGroup -Name "myNsgPrivate" -ResourceGroupName $rgName

Set-AzVirtualNetworkSubnetConfig `
    -VirtualNetwork $vnet `
    -Name "Private" `
    -AddressPrefix "10.0.1.0/24" `
    -ServiceEndpoint "Microsoft.Storage" `
    -NetworkSecurityGroup $nsg
$vnet | Set-AzVirtualNetwork

Write-Host "Configuring storage firewall (allow only Private subnet)..." -ForegroundColor Cyan
$subnet = Get-AzVirtualNetwork -ResourceGroupName $rgName -Name "myVirtualNetwork" | 
    Get-AzVirtualNetworkSubnetConfig -Name "Private"

Add-AzStorageAccountNetworkRule `
    -ResourceGroupName $rgName `
    -Name $storageAccountName `
    -VirtualNetworkResourceId $subnet.Id

Update-AzStorageAccountNetworkRuleSet `
    -ResourceGroupName $rgName `
    -Name $storageAccountName `
    -DefaultAction Deny

Write-Host "`nStorage Account created: $storageAccountName" -ForegroundColor Green
Write-Host "Go to Portal → Storage → File Shares → my-file-share → Connect" -ForegroundColor Yellow
Write-Host "Copy PowerShell script for drive mapping (needed in Task 7)" -ForegroundColor Yellow
