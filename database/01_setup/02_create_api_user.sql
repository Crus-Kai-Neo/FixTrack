-- ============================================================================
-- Dedicated SQL Login & Database User for Node.js / Express.js Backend
-- File: 01_setup/02_create_api_user.sql
-- ============================================================================

USE master;
GO

IF NOT EXISTS (SELECT name FROM sys.server_principals WHERE name = N'fixtrack_api')
BEGIN
    CREATE LOGIN fixtrack_api
        WITH PASSWORD = N'FixTrack@2026!',
             DEFAULT_DATABASE = FixTrackDB,
             CHECK_EXPIRATION = OFF,
             CHECK_POLICY = ON;
    PRINT 'Server login fixtrack_api created.';
END
GO

USE FixTrackDB;
GO

IF NOT EXISTS (SELECT name FROM sys.database_principals WHERE name = N'fixtrack_api')
BEGIN
    CREATE USER fixtrack_api FOR LOGIN fixtrack_api;
    ALTER ROLE db_datareader ADD MEMBER fixtrack_api;
    ALTER ROLE db_datawriter ADD MEMBER fixtrack_api;
    GRANT EXECUTE TO fixtrack_api; -- Allows calling stored procedures in 03_programmability
    PRINT 'Database user fixtrack_api configured with read, write, and execute permissions.';
END
GO