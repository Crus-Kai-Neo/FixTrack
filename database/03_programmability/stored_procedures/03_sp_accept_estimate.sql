USE FixTrackDB;
GO

CREATE OR ALTER PROCEDURE dbo.sp_AcceptEstimate
    @estimate_id INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @request_id INT;
        DECLARE @shop_owner_id INT;
        DECLARE @ref_number VARCHAR(25);

        SELECT
            @request_id = e.request_id,
            @shop_owner_id = s.owner_user_id,
            @ref_number = r.reference_number
        FROM dbo.Estimates e
        INNER JOIN dbo.Requests r ON e.request_id = r.request_id
        INNER JOIN dbo.Shops s ON r.shop_id = s.shop_id
        WHERE e.estimate_id = @estimate_id;

        IF @request_id IS NULL
            THROW 50002, 'Estimate not found.', 1;

        -- 1. Update estimate status
        UPDATE dbo.Estimates
        SET estimate_status = 'Accepted'
        WHERE estimate_id = @estimate_id;

        -- 2. Create confirmed booking
        INSERT INTO dbo.Bookings (request_id, estimate_id, current_repair_status)
        VALUES (@request_id, @estimate_id, 'Received');

        DECLARE @new_booking_id INT = SCOPE_IDENTITY();

        -- 3. Record initial repair status history entry
        INSERT INTO dbo.Repair_Status_History (booking_id, status, remarks)
        VALUES (@new_booking_id, 'Received', N'Estimate accepted by customer. Booking confirmed.');

        -- 4. Notify shop owner
        INSERT INTO dbo.Notifications (user_id, request_id, message)
        VALUES (@shop_owner_id, @request_id, N'Customer accepted estimate for ' + @ref_number + N'. Booking #' + CAST(@new_booking_id AS NVARCHAR(10)) + N' created.');

        COMMIT TRANSACTION;

        SELECT @new_booking_id AS booking_id;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO