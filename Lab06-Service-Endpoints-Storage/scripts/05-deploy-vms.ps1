# Lab 06 - Task 6: Deploy Virtual Machines

$rgName = "AZ500LAB12"
$location = "eastus"

Write-Host "Enter VM credentials (Username: Student)" -ForegroundColor Yellow
$credential = Get-Credential

$vnet = Get-AzVirtualNetwork -ResourceGroupName $rgName -Name "myVirtualNetwork"

# ========================================
# VM 1: myVmPrivate (Private subnet)
# ========================================

Write-Host "`n[1/2] Creating myVmPrivate in Private subnet..." -ForegroundColor Cyan

$privateSubnet = Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name "Private"

# Create Public IP
$pipPrivate = New-AzPublicIpAddress `
    -ResourceGroupName $rgName `
    -Location $location `
    -Name "myVmPrivate-ip" `
    -AllocationMethod Dynamic

# Create NIC
$nicPrivate = New-AzNetworkInterface `
    -ResourceGroupName $rgName `
    -Location $location `
    -Name "myVmPrivate-nic" `
    -SubnetId $privateSubnet.Id `
    -PublicIpAddressId $pipPrivate.Id

# Create VM config
$vmConfigPrivate = New-AzVMConfig -VMName "myVmPrivate" -VMSize "Standard_DS1_v2" |
    Set-AzVMOperatingSystem -Windows -ComputerName "myVmPrivate" -Credential $credential |
    Set-AzVMSourceImage `
        -PublisherName MicrosoftWindowsServer `
        -Offer WindowsServer `
        -Skus 2022-datacenter-azure-edition `
        -Version latest |
    Add-AzVMNetworkInterface -Id $nicPrivate.Id |
    Set-AzVMOSDisk -StorageAccountType Standard_HDD -CreateOption FromImage

# Create VM
New-AzVM -ResourceGroupName $rgName -Location $location -VM $vmConfigPrivate

Write-Host "myVmPrivate created successfully" -ForegroundColor Green

# ========================================
# VM 2: myVmPublic (Public subnet)
# ========================================

Write-Host "`n[2/2] Creating myVmPublic in Public subnet..." -ForegroundColor Cyan

$publicSubnet = Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name "Public"

# Create Public IP
$pipPublic = New-AzPublicIpAddress `
    -ResourceGroupName $rgName `
    -Location $location `
    -Name "myVmPublic-ip" `
    -AllocationMethod Dynamic

# Create NIC
$nicPublic = New-AzNetworkInterface `
    -ResourceGroupName $rgName `
    -Location $location `
    -Name "myVmPublic-nic" `
    -SubnetId $publicSubnet.Id `
    -PublicIpAddressId $pipPublic.Id

# Create VM config
$vmConfigPublic = New-AzVMConfig -VMName "myVmPublic" -VMSize "Standard_DS1_v2" |
    Set-AzVMOperatingSystem -Windows -ComputerName "myVmPublic" -Credential $credential |
    Set-AzVMSourceImage `
        -PublisherName MicrosoftWindowsServer `
        -Offer WindowsServer `
        -Skus 2022-datacenter-azure-edition `
        -Version latest |
    Add-AzVMNetworkInterface -Id $nicPublic.Id |
    Set-AzVMOSDisk -StorageAccountType Standard_HDD -CreateOption FromImage

# Create VM
New-AzVM -ResourceGroupName $rgName -Location $location -VM $vmConfigPublic

Write-Host "myVmPublic created successfully" -ForegroundColor Green

Write-Host "`n=== Both VMs deployed ===" -ForegroundColor Green
Write-Host "myVmPrivate: Private subnet (10.0.1.0/24)" -ForegroundColor Cyan
Write-Host "myVmPublic: Public subnet (10.0.0.0/24)" -ForegroundColor Cyan
Write-Host "`nProceed to Task 7 for testing" -ForegroundColor Yellow
