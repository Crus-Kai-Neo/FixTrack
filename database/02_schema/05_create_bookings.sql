USE FixTrackDB;
GO

IF OBJECT_ID('dbo.Bookings', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Bookings (
        booking_id             INT IDENTITY(1,1) PRIMARY KEY,
        request_id             INT         NOT NULL UNIQUE,
        estimate_id            INT         NOT NULL UNIQUE,
        current_repair_status  VARCHAR(20) NOT NULL DEFAULT 'Received'
            CONSTRAINT CK_Bookings_RepairStatus CHECK (
                current_repair_status IN ('Received', 'Diagnosing', 'Repairing', 'Ready', 'Collected')
            ),
        confirmed_at           DATETIME2   NOT NULL DEFAULT GETDATE(),

        CONSTRAINT FK_Bookings_Request
            FOREIGN KEY (request_id) REFERENCES dbo.Requests(request_id),
        CONSTRAINT FK_Bookings_Estimate
            FOREIGN KEY (estimate_id) REFERENCES dbo.Estimates(estimate_id)
    );
END
GO