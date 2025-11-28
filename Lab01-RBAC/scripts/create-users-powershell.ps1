<#
.SYNOPSIS
    Create Azure AD users using PowerShell for RBAC lab
.DESCRIPTION
    Demonstrates user creation via PowerShell for automation scenarios
    Part of AZ-500 Lab 01: RBAC implementation
.NOTES
    Requires: Az.Resources module
    Author: [Your Name]
#>

# Connect to Azure (interactive login)
Connect-AzAccount

# Variables
$PasswordProfile = @{
    Password = "Pa55w.rd1234"  # Change this in production!
    ForceChangePasswordNextSignIn = $true
}

# Create user Isabel Garcia
$UserParams = @{
    DisplayName = "Isabel Garcia"
    UserPrincipalName = "Isabel@yourdomain.onmicrosoft.com"
    AccountEnabled = $true
    PasswordProfile = $PasswordProfile
    MailNickname = "Isabel"
}

try {
    New-AzADUser @UserParams
    Write-Host "✅ User Isabel Garcia created successfully via PowerShell" -ForegroundColor Green
}
catch {
    Write-Host "❌ Error creating user: $_" -ForegroundColor Red
}

# Note: In production, use secure password handling (Key Vault, parameters, etc.)
