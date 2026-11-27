USE FixTrackDB;
GO

CREATE OR ALTER PROCEDURE dbo.sp_CreateRepairRequest
    @customer_id         INT,
    @shop_id             INT,
    @device_type         NVARCHAR(50),
    @device_model        NVARCHAR(100),
    @problem_description NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @new_request_id INT;
        DECLARE @ref_number VARCHAR(25);
        DECLARE @shop_owner_id INT;

        -- Generate unique reference number (e.g., FIX-20261125-4821)
        SET @ref_number = 'FIX-' + CONVERT(VARCHAR(8), GETDATE(), 112) + '-' + RIGHT('0000' + CAST(ABS(CHECKSUM(NEWID())) % 10000 AS VARCHAR(4)), 4);

        INSERT INTO dbo.Requests (reference_number, customer_id, shop_id, device_type, device_model, problem_description)
        VALUES (@ref_number, @customer_id, @shop_id, @device_type, @device_model, @problem_description);

        SET @new_request_id = SCOPE_IDENTITY();

        -- Notify shop owner
        SELECT @shop_owner_id = owner_user_id FROM dbo.Shops WHERE shop_id = @shop_id;

        IF @shop_owner_id IS NOT NULL
        BEGIN
            INSERT INTO dbo.Notifications (user_id, request_id, message)
            VALUES (@shop_owner_id, @new_request_id, N'New repair request (' + @ref_number + N') received for ' + @device_model + N'.');
        END

        COMMIT TRANSACTION;

        SELECT @new_request_id AS request_id, @ref_number AS reference_number;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO