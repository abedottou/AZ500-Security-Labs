-- Lab 07 - Always Encrypted Configuration Script
-- NOTE: This script documents the process done via SSMS GUI

/*
STEP 1: Create Column Master Key (CMK)
---------------------------------------
1. In SSMS, connect to Azure SQL Database
2. Expand: Databases → medical → Security → Always Encrypted Keys
3. Right-click "Column Master Keys" → New Column Master Key
4. Settings:
   - Name: CMK_Auto1
   - Key Store: Azure Key Vault
   - Sign in to Azure
   - Select Key Vault: AZ500-KV-xxxxx
   - Select Key: MyLabKey
5. Click OK

STEP 2: Create Column Encryption Key (CEK)
------------------------------------------
1. Right-click "Column Encryption Keys" → New Column Encryption Key
2. Settings:
   - Name: CEK_Auto1
   - Column Master Key: CMK_Auto1
3. Click OK (encrypted value auto-generated)

STEP 3: Verify Configuration
----------------------------
*/

-- View Column Master Keys
SELECT * FROM sys.column_master_keys;
GO

-- View Column Encryption Keys
SELECT * FROM sys.column_encryption_keys;
GO

-- View encrypted column metadata
SELECT 
    c.name AS column_name,
    t.name AS table_name,
    et.encryption_type_desc,
    cek.name AS encryption_key_name
FROM sys.columns c
JOIN sys.tables t ON c.object_id = t.object_id
JOIN sys.column_encryption_keys cek ON c.column_encryption_key_id = cek.column_encryption_key_id
JOIN sys.column_encryption_key_values cekv ON cek.column_encryption_key_id = cekv.column_encryption_key_id
JOIN sys.column_encryption_types et ON c.encryption_type = et.encryption_type_id
WHERE t.name = 'Patients';
GO

/*
Expected Output:
column_name | table_name | encryption_type_desc | encryption_key_name
---------------------------------------------------------------------------
SSN         | Patients   | DETERMINISTIC        | CEK_Auto1
BirthDate   | Patients   | RANDOMIZED           | CEK_Auto1
*/
