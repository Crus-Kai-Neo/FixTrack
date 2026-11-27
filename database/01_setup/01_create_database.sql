-- ============================================================================
-- FixTrack Database Initialization
-- File: 01_setup/01_create_database.sql
-- ============================================================================

USE master;
GO

IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'FixTrackDB')
BEGIN
    CREATE DATABASE FixTrackDB;
    PRINT 'Database FixTrackDB created successfully.';
END
ELSE
BEGIN
    PRINT 'Database FixTrackDB already exists.';
END
GO

USE FixTrackDB;
GO