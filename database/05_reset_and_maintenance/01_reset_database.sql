USE FixTrackDB;
GO

-- Delete in strict child-to-parent Foreign Key order
DELETE FROM dbo.Notifications;
DELETE FROM dbo.Repair_Status_History;
DELETE FROM dbo.Bookings;
DELETE FROM dbo.Estimates;
DELETE FROM dbo.Requests;
DELETE FROM dbo.Shops;
DELETE FROM dbo.Users;

-- Reset IDENTITY counters back to 1
DBCC CHECKIDENT ('dbo.Notifications', RESEED, 0);
DBCC CHECKIDENT ('dbo.Repair_Status_History', RESEED, 0);
DBCC CHECKIDENT ('dbo.Bookings', RESEED, 0);
DBCC CHECKIDENT ('dbo.Estimates', RESEED, 0);
DBCC CHECKIDENT ('dbo.Requests', RESEED, 0);
DBCC CHECKIDENT ('dbo.Shops', RESEED, 0);
DBCC CHECKIDENT ('dbo.Users', RESEED, 0);

PRINT 'All tables cleared and identity counters reset to 0.';
GO