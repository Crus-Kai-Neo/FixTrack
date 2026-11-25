USE FixTrackDB;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Requests_CustomerId')
    CREATE INDEX IX_Requests_CustomerId ON dbo.Requests(customer_id);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Requests_ShopId')
    CREATE INDEX IX_Requests_ShopId ON dbo.Requests(shop_id);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Notifications_UserId')
    CREATE INDEX IX_Notifications_UserId ON dbo.Notifications(user_id);
GO