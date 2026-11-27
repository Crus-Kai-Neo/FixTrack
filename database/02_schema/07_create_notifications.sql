USE FixTrackDB;
GO

IF OBJECT_ID('dbo.Notifications', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Notifications (
        notification_id  INT IDENTITY(1,1) PRIMARY KEY,
        user_id          INT           NOT NULL,
        request_id       INT           NULL,
        message          NVARCHAR(255) NOT NULL,
        is_read          BIT           NOT NULL DEFAULT 0,
        created_at       DATETIME2     NOT NULL DEFAULT GETDATE(),

        CONSTRAINT FK_Notifications_User
            FOREIGN KEY (user_id) REFERENCES dbo.Users(user_id),
        CONSTRAINT FK_Notifications_Request
            FOREIGN KEY (request_id) REFERENCES dbo.Requests(request_id)
    );
END
GO