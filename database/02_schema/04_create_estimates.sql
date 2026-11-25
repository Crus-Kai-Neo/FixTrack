USE FixTrackDB;
GO

IF OBJECT_ID('dbo.Estimates', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Estimates (
        estimate_id                INT IDENTITY(1,1) PRIMARY KEY,
        request_id                 INT            NOT NULL UNIQUE,
        estimated_cost             DECIMAL(10, 2) NOT NULL
            CONSTRAINT CK_Estimates_Cost CHECK (estimated_cost > 0),
        estimated_completion_time  NVARCHAR(80)   NOT NULL,
        business_notes             NVARCHAR(500)  NULL,
        estimate_status            VARCHAR(25)    NOT NULL DEFAULT 'Sent'
            CONSTRAINT CK_Estimates_Status CHECK (estimate_status IN ('Sent', 'Accepted', 'Rejected')),
        sent_at                    DATETIME2      NOT NULL DEFAULT GETDATE(),

        CONSTRAINT FK_Estimates_Request
            FOREIGN KEY (request_id) REFERENCES dbo.Requests(request_id)
    );
END
GO