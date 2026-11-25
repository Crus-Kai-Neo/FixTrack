USE FixTrackDB;
GO

-- 1. Customer Dashboard View: Shows requests, shop details, estimates, and live booking status
CREATE OR ALTER VIEW dbo.vw_CustomerRepairDashboard AS
SELECT
    r.request_id,
    r.reference_number,
    r.customer_id,
    c.full_name           AS customer_name,
    r.shop_id,
    s.shop_name,
    s.contact_phone       AS shop_phone,
    r.device_type,
    r.device_model,
    r.problem_description,
    r.request_status,
    r.created_at          AS requested_at,
    e.estimate_id,
    e.estimated_cost,
    e.estimated_completion_time,
    e.business_notes,
    e.estimate_status,
    e.sent_at             AS estimate_sent_at,
    b.booking_id,
    b.current_repair_status,
    b.confirmed_at        AS booking_confirmed_at
FROM dbo.Requests r
INNER JOIN dbo.Users c ON r.customer_id = c.user_id
INNER JOIN dbo.Shops s ON r.shop_id = s.shop_id
LEFT JOIN dbo.Estimates e ON r.request_id = e.request_id
LEFT JOIN dbo.Bookings b ON r.request_id = b.request_id;
GO

-- 2. Shop Dashboard View: Shows incoming requests, customer contact info, estimates, and active repairs
CREATE OR ALTER VIEW dbo.vw_ShopRepairDashboard AS
SELECT
    s.shop_id,
    s.owner_user_id,
    s.shop_name,
    r.request_id,
    r.reference_number,
    r.customer_id,
    c.full_name           AS customer_name,
    c.phone               AS customer_phone,
    c.email               AS customer_email,
    r.device_type,
    r.device_model,
    r.problem_description,
    r.request_status,
    r.created_at          AS requested_at,
    e.estimate_id,
    e.estimated_cost,
    e.estimated_completion_time,
    e.estimate_status,
    b.booking_id,
    b.current_repair_status,
    b.confirmed_at
FROM dbo.Shops s
INNER JOIN dbo.Requests r ON s.shop_id = r.shop_id
INNER JOIN dbo.Users c ON r.customer_id = c.user_id
LEFT JOIN dbo.Estimates e ON r.request_id = e.request_id
LEFT JOIN dbo.Bookings b ON r.request_id = b.request_id;
GO