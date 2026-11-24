USE FixTrackDB;
GO

IF OBJECT_ID('dbo.Requests', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Requests (
        request_id           INT IDENTITY(1,1) PRIMARY KEY,
        reference_number     VARCHAR(25)   NOT NULL UNIQUE,
        customer_id          INT           NOT NULL,
        shop_id              INT           NOT NULL,
        device_type          NVARCHAR(50)  NOT NULL,
        device_model         NVARCHAR(100) NOT NULL,
        problem_description  NVARCHAR(MAX) NOT NULL,
        request_status       VARCHAR(25)   NOT NULL DEFAULT 'Pending'
            CONSTRAINT CK_Requests_Status CHECK (request_status IN ('Pending', 'Accepted', 'Rejected')),
        created_at           DATETIME2     NOT NULL DEFAULT GETDATE(),

        CONSTRAINT FK_Requests_Customer
            FOREIGN KEY (customer_id) REFERENCES dbo.Users(user_id),
        CONSTRAINT FK_Requests_Shop
            FOREIGN KEY (shop_id) REFERENCES dbo.Shops(shop_id)
    );
END
GO