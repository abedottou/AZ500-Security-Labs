#!/bin/bash
#
# Create Azure AD users using Azure CLI
# Part of AZ-500 Lab 01: RBAC implementation
# Author: [Your Name]
#

# Login to Azure
az login

# Variables
USER_NAME="Dylan Williams"
UPN="Dylan@yourdomain.onmicrosoft.com"
PASSWORD="Pa55w.rd1234"  # Change this in production!

# Create user Dylan Williams
az ad user create \
  --display-name "$USER_NAME" \
  --user-principal-name "$UPN" \
  --password "$PASSWORD" \
  --force-change-password-next-sign-in true

if [ $? -eq 0 ]; then
    echo "✅ User $USER_NAME created successfully via Azure CLI"
else
    echo "❌ Error creating user"
    exit 1
fi

# Best practice: Use Azure Key Vault for password management in production
