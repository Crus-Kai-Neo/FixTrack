USE FixTrackDB;
GO

IF OBJECT_ID('dbo.Users', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Users (
        user_id        INT IDENTITY(1,1) PRIMARY KEY,
        full_name      NVARCHAR(100) NOT NULL,
        email          NVARCHAR(120) NOT NULL UNIQUE,
        phone          VARCHAR(20)   NOT NULL,
        password_hash  NVARCHAR(255) NOT NULL,
        role           VARCHAR(20)   NOT NULL
            CONSTRAINT CK_Users_Role CHECK (role IN ('Customer', 'Business')),
        created_at     DATETIME2     NOT NULL DEFAULT GETDATE()
    );
END
GO