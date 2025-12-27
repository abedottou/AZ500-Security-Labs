# Lab 11 - Create Log Analytics Workspace for Sentinel

$rgName = "AZ500LAB131415"
$location = "eastus"
$workspaceName = "LAW$(Get-Random -Maximum 99999999)"

Write-Host "Creating Log Analytics Workspace for Sentinel..." -ForegroundColor Cyan

# Create Resource Group if not exists
$rg = Get-AzResourceGroup -Name $rgName -ErrorAction SilentlyContinue
if (-not $rg) {
    New-AzResourceGroup -Name $rgName -Location $location
}

# Create workspace
New-AzOperationalInsightsWorkspace `
    -ResourceGroupName $rgName `
    -Name $workspaceName `
    -Location $location `
    -Sku PerGB2018 `
    -RetentionInDays 90

Write-Host "✅ Workspace created: $workspaceName" -ForegroundColor Green
Write-Host "`nNext: Enable Sentinel on this workspace via Portal" -ForegroundColor Yellow
