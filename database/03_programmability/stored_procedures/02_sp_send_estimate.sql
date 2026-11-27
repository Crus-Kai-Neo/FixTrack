USE FixTrackDB;
GO

CREATE OR ALTER PROCEDURE dbo.sp_SendEstimate
    @request_id                INT,
    @estimated_cost            DECIMAL(10, 2),
    @estimated_completion_time NVARCHAR(80),
    @business_notes            NVARCHAR(500) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @customer_id INT;
        DECLARE @ref_number VARCHAR(25);

        SELECT @customer_id = customer_id, @ref_number = reference_number
        FROM dbo.Requests
        WHERE request_id = @request_id;

        IF @customer_id IS NULL
            THROW 50001, 'Repair request not found.', 1;

        -- Mark request as Accepted and insert estimate
        UPDATE dbo.Requests
        SET request_status = 'Accepted'
        WHERE request_id = @request_id;

        INSERT INTO dbo.Estimates (request_id, estimated_cost, estimated_completion_time, business_notes)
        VALUES (@request_id, @estimated_cost, @estimated_completion_time, @business_notes);

        DECLARE @new_estimate_id INT = SCOPE_IDENTITY();

        -- Notify customer
        INSERT INTO dbo.Notifications (user_id, request_id, message)
        VALUES (@customer_id, @request_id, N'You received a repair estimate of $' + CAST(@estimated_cost AS NVARCHAR(20)) + N' for request ' + @ref_number + N'.');

        COMMIT TRANSACTION;

        SELECT @new_estimate_id AS estimate_id;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO