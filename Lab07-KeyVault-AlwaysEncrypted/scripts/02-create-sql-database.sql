-- Lab 07 - Create Medical Database with Always Encrypted

-- Create Patients table with encrypted columns
USE medical;
GO

-- Drop table if exists
IF OBJECT_ID('dbo.Patients', 'U') IS NOT NULL
    DROP TABLE dbo.Patients;
GO

-- Create table with Always Encrypted columns
CREATE TABLE Patients (
    PatientId INT IDENTITY(1,1) PRIMARY KEY,
    
    -- SSN: Deterministic encryption (allows WHERE queries)
    SSN CHAR(11) COLLATE Latin1_General_BIN2 
        ENCRYPTED WITH (
            ENCRYPTION_TYPE = DETERMINISTIC,
            ALGORITHM = 'AEAD_AES_256_CBC_HMAC_SHA_256',
            COLUMN_ENCRYPTION_KEY = CEK_Auto1
        ) NOT NULL,
    
    -- FirstName: Not encrypted (allows full-text search)
    FirstName VARCHAR(50) NOT NULL,
    
    -- LastName: Not encrypted
    LastName VARCHAR(50) NOT NULL,
    
    -- BirthDate: Randomized encryption (maximum security)
    BirthDate DATE 
        ENCRYPTED WITH (
            ENCRYPTION_TYPE = RANDOMIZED,
            ALGORITHM = 'AEAD_AES_256_CBC_HMAC_SHA_256',
            COLUMN_ENCRYPTION_KEY = CEK_Auto1
        ) NOT NULL,
    
    -- Created timestamp
    CreatedAt DATETIME2 DEFAULT GETUTCDATE()
);
GO

-- Insert sample data
INSERT INTO Patients (SSN, FirstName, LastName, BirthDate)
VALUES 
    ('999-99-0001', 'John', 'Doe', '1985-05-15'),
    ('999-99-0002', 'Jane', 'Smith', '1990-08-22'),
    ('999-99-0003', 'Alice', 'Johnson', '1978-12-03'),
    ('999-99-0004', 'Bob', 'Williams', '1982-11-30'),
    ('999-99-0005', 'Carol', 'Davis', '1995-03-18');
GO

-- Query to verify (will show encrypted data)
SELECT * FROM Patients;
GO
