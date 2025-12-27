# Lab 08 - Task 3: Create Data Collection Rule (DCR)
# Note: DCR creation is easiest via Portal
# This script shows ARM template deployment method

$rgName = "AZ500LAB131415"
$location = "eastus"
$dcrName = "DCR1"
$workspaceName = "LAW*" # Replace with actual name

Write-Host "Getting Log Analytics Workspace..." -ForegroundColor Cyan
$workspace = Get-AzOperationalInsightsWorkspace `
    -ResourceGroupName $rgName `
    -Name $workspaceName

if (-not $workspace) {
    Write-Error "Workspace not found. Run 02-create-log-analytics.ps1 first"
    exit
}

Write-Host "Deploying DCR via ARM template..." -ForegroundColor Cyan

# ARM template deployment
$templateFile = "03-create-dcr-template.json"

New-AzResourceGroupDeployment `
    -ResourceGroupName $rgName `
    -TemplateFile $templateFile `
    -workspaceResourceId $workspace.ResourceId `
    -dcrName $dcrName

Write-Host "DCR created successfully" -ForegroundColor Green

# Install Azure Monitor Agent
Write-Host "`nInstalling Azure Monitor Agent on myVM..." -ForegroundColor Cyan

Set-AzVMExtension `
    -ExtensionName "AzureMonitorWindowsAgent" `
    -ResourceGroupName $rgName `
    -VMName "myVM" `
    -Publisher "Microsoft.Azure.Monitor" `
    -ExtensionType "AzureMonitorWindowsAgent" `
    -TypeHandlerVersion "1.0" `
    -Location $location

Write-Host "Azure Monitor Agent installed" -ForegroundColor Green

# Associate DCR with VM
Write-Host "`nAssociating DCR with VM..." -ForegroundColor Cyan

$vm = Get-AzVM -ResourceGroupName $rgName -Name "myVM"
$dcr = Get-AzDataCollectionRule -ResourceGroupName $rgName -Name $dcrName

New-AzDataCollectionRuleAssociation `
    -ResourceUri $vm.Id `
    -DataCollectionRuleId $dcr.Id `
    -AssociationName "dcr-myvm-association"

Write-Host "DCR associated with VM successfully" -ForegroundColor Green
Write-Host "`nWait 5-10 minutes for data to appear in Log Analytics" -ForegroundColor Yellow
