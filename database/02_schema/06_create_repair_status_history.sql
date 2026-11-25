USE FixTrackDB;
GO

IF OBJECT_ID('dbo.Repair_Status_History', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Repair_Status_History (
        history_id  INT IDENTITY(1,1) PRIMARY KEY,
        booking_id  INT           NOT NULL,
        status      VARCHAR(20)   NOT NULL
            CONSTRAINT CK_History_Status CHECK (
                status IN ('Received', 'Diagnosing', 'Repairing', 'Ready', 'Collected')
            ),
        remarks     NVARCHAR(300) NULL,
        updated_at  DATETIME2     NOT NULL DEFAULT GETDATE(),

        CONSTRAINT FK_History_Booking
            FOREIGN KEY (booking_id) REFERENCES dbo.Bookings(booking_id)
    );
END
GO