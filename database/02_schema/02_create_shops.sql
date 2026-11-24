USE FixTrackDB;
GO

IF OBJECT_ID('dbo.Shops', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Shops (
        shop_id            INT IDENTITY(1,1) PRIMARY KEY,
        owner_user_id      INT           NOT NULL,
        shop_name          NVARCHAR(120) NOT NULL,
        address            NVARCHAR(200) NOT NULL,
        specialization     NVARCHAR(200) NULL,
        contact_phone      VARCHAR(20)   NOT NULL,
        opening_hours      NVARCHAR(80)  NULL,
        supported_devices  NVARCHAR(200) NULL,
        created_at         DATETIME2     NOT NULL DEFAULT GETDATE(),

        CONSTRAINT FK_Shops_OwnerUser
            FOREIGN KEY (owner_user_id) REFERENCES dbo.Users(user_id)
    );
END
GO