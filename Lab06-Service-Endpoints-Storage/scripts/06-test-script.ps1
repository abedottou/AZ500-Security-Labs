# Lab 06 - Test Script
# Run this inside VMs via RDP (Tasks 7 & 8)

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "Lab 06 - Storage Access Test Script" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan

# ========================================
# Test 1: Map Z: drive to file share
# ========================================

Write-Host "`n[Test 1] Mapping Z: drive to file share..." -ForegroundColor Yellow
Write-Host "Paste the PowerShell script from Portal below:" -ForegroundColor Yellow
Write-Host "(Storage Account → File Shares → my-file-share → Connect → Windows tab)" -ForegroundColor Yellow
Write-Host ""

# PASTE THE DRIVE MAPPING SCRIPT HERE
# Example format:
# $connectTestResult = Test-NetConnection -ComputerName az500lab12stXXXXX.file.core.windows.net -Port 445
# if ($connectTestResult.TcpTestSucceeded) {
#     cmd.exe /C "cmdkey /add:`"az500lab12stXXXXX.file.core.windows.net`" /user:`"localhost\az500lab12stXXXXX`" /pass:`"STORAGE_ACCOUNT_KEY`""
#     New-PSDrive -Name Z -PSProvider FileSystem -Root "\\az500lab12stXXXXX.file.core.windows.net\my-file-share" -Persist
# } else {
#     Write-Error -Message "Unable to reach the Azure storage account via port 445."
# }

Write-Host "`n--- Test 1 Results ---" -ForegroundColor Cyan
Write-Host "Check if Z: drive appeared in File Explorer" -ForegroundColor White
Write-Host ""

# Expected results:
# myVmPrivate: ✅ Z: drive mapped successfully
# myVmPublic:  ❌ New-PSDrive : Access is denied

# ========================================
# Test 2: Internet connectivity test
# ========================================

Write-Host "`n[Test 2] Testing Internet connectivity to www.bing.com..." -ForegroundColor Yellow

$internetTest = Test-NetConnection -ComputerName www.bing.com -Port 80

Write-Host "`n--- Test 2 Results ---" -ForegroundColor Cyan
Write-Host "Computer Name: $($internetTest.ComputerName)" -ForegroundColor White
Write-Host "Remote Address: $($internetTest.RemoteAddress)" -ForegroundColor White
Write-Host "TCP Test Succeeded: $($internetTest.TcpTestSucceeded)" -ForegroundColor White

if ($internetTest.TcpTestSucceeded) {
    Write-Host "`n✅ Internet Access: ALLOWED" -ForegroundColor Green
} else {
    Write-Host "`n❌ Internet Access: DENIED" -ForegroundColor Red
}

# Expected results:
# myVmPrivate: ❌ TcpTestSucceeded = False (NSG blocks)
# myVmPublic:  ✅ TcpTestSucceeded = True (NSG allows)

Write-Host "`n==================================================" -ForegroundColor Cyan
Write-Host "Test completed" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
