# Lab 06 - Test Script (Run inside VMs via RDP)

# Test 1: Map drive to file share
Write-Host "`n=== Test 1: Map Z: drive to file share ===" -ForegroundColor Cyan
# Paste the drive mapping script from Portal here
# Script format:
# $connectTestResult = Test-NetConnection -ComputerName <storage>.file.core.windows.net -Port 445
# if ($connectTestResult.TcpTestSucceeded) {
#     cmd.exe /C "cmdkey /add:..."
#     New-PSDrive -Name Z -PSProvider FileSystem -Root "\\<storage>.file.core.windows.net\my-file-share" -Persist
# }

# Test 2: Check Internet connectivity
Write-Host "`n=== Test 2: Test Internet connectivity ===" -ForegroundColor Cyan
Test-NetConnection -ComputerName www.bing.com -Port 80
