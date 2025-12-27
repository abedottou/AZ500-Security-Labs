# Lab 08 - Task 2: Create Log Analytics Workspace

$rgName = "AZ500LAB131415"
$location = "eastus"
$workspaceName = "LAW$(Get-Random -Maximum 99999999)"

Write-Host "Creating Log Analytics Workspace: $workspaceName" -ForegroundColor Cyan

New-AzOperationalInsightsWorkspace `
    -ResourceGroupName $rgName `
    -Name $workspaceName `
    -Location $location `
    -Sku PerGB2018 `
    -RetentionInDays 31

Write-Host "Log Analytics Workspace created successfully" -ForegroundColor Green
Write-Host "Workspace Name: $workspaceName" -ForegroundColor Yellow

# Get Workspace details
$workspace = Get-AzOperationalInsightsWorkspace `
    -ResourceGroupName $rgName `
    -Name $workspaceName

Write-Host "`nWorkspace Details:" -ForegroundColor Cyan
Write-Host "Resource ID: $($workspace.ResourceId)" -ForegroundColor White
Write-Host "Workspace ID: $($workspace.CustomerId)" -ForegroundColor White
