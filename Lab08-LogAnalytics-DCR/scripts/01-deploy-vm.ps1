# Lab 08 - Task 1: Deploy Azure VM

$rgName = "AZ500LAB131415"
$location = "eastus"
$vmName = "myVM"
$vmSize = "Standard_DS1_v2"

Write-Host "Creating Resource Group: $rgName" -ForegroundColor Cyan
New-AzResourceGroup -Name $rgName -Location $location

Write-Host "Creating VM: $vmName" -ForegroundColor Cyan

# VM credentials
$vmUser = "Student"
$vmPassword = ConvertTo-SecureString "Pa55w.rd1234AZ500" -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential ($vmUser, $vmPassword)

# Create VM
New-AzVm `
    -ResourceGroupName $rgName `
    -Name $vmName `
    -Location $location `
    -Size $vmSize `
    -Image "Win2022Datacenter" `
    -Credential $credential `
    -OpenPorts 3389 `
    -PublicIpAddressName "$vmName-ip" `
    -VirtualNetworkName "$vmName-vnet" `
    -SubnetName "default" `
    -SecurityGroupName "$vmName-nsg"

Write-Host "VM deployed successfully" -ForegroundColor Green
Get-AzVM -ResourceGroupName $rgName -Name $vmName | Select-Object Name, Location, ProvisioningState
