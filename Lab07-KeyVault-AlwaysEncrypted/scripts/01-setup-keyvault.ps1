# Lab 07 - Azure Key Vault Setup
# Description: Creates Key Vault, CMK, and configures access policies

# Variables
$rgName = "AZ500LAB07"
$location = "EastUS"
$kvName = "AZ500-KV-$(Get-Random -Maximum 99999)"
$keyName = "MyLabKey"

# Create Resource Group
Write-Host "Creating Resource Group: $rgName" -ForegroundColor Cyan
New-AzResourceGroup -Name $rgName -Location $location

# Create Key Vault
Write-Host "Creating Key Vault: $kvName" -ForegroundColor Cyan
New-AzKeyVault `
    -ResourceGroupName $rgName `
    -VaultName $kvName `
    -Location $location `
    -EnabledForDiskEncryption `
    -EnabledForTemplateDeployment `
    -EnableSoftDelete `
    -SoftDeleteRetentionInDays 90 `
    -Sku Standard

# Create Column Master Key
Write-Host "Creating Column Master Key: $keyName" -ForegroundColor Cyan
$key = Add-AzKeyVaultKey `
    -VaultName $kvName `
    -Name $keyName `
    -Destination Software

# Create Secret for SQL Password
Write-Host "Creating SQL Password Secret" -ForegroundColor Cyan
$sqlPassword = ConvertTo-SecureString "P@ssw0rd123!AZ500" -AsPlainText -Force
Set-AzKeyVaultSecret `
    -VaultName $kvName `
    -Name "SQLPassword" `
    -SecretValue $sqlPassword

# Output Key Vault information
Write-Host "`n=== Key Vault Information ===" -ForegroundColor Green
Write-Host "Key Vault Name: $kvName"
Write-Host "Key Vault URI: $($key.VaultName)"
Write-Host "Key Name: $keyName"
Write-Host "Key ID: $($key.Id)"
Write-Host "`nSave these values for SQL Always Encrypted configuration" -ForegroundColor Yellow
