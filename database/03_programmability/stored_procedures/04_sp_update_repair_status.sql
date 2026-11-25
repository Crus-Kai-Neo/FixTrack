USE FixTrackDB;
GO

CREATE OR ALTER PROCEDURE dbo.sp_UpdateRepairStatus
    @booking_id INT,
    @new_status VARCHAR(20),
    @remarks    NVARCHAR(300) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @request_id INT;
        DECLARE @customer_id INT;
        DECLARE @ref_number VARCHAR(25);

        SELECT
            @request_id = b.request_id,
            @customer_id = r.customer_id,
            @ref_number = r.reference_number
        FROM dbo.Bookings b
        INNER JOIN dbo.Requests r ON b.request_id = r.request_id
        WHERE b.booking_id = @booking_id;

        IF @request_id IS NULL
            THROW 50003, 'Booking not found.', 1;

        -- 1. Update current status on Booking
        UPDATE dbo.Bookings
        SET current_repair_status = @new_status
        WHERE booking_id = @booking_id;

        -- 2. Append to Repair_Status_History timeline
        INSERT INTO dbo.Repair_Status_History (booking_id, status, remarks)
        VALUES (@booking_id, @new_status, @remarks);

        -- 3. Notify customer
        INSERT INTO dbo.Notifications (user_id, request_id, message)
        VALUES (@customer_id, @request_id, N'Repair status for ' + @ref_number + N' updated to: ' + @new_status + N'.');

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO