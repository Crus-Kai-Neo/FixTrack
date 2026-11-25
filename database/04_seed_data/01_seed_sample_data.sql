USE FixTrackDB;
GO

-- Only seed if Users table is currently empty
IF NOT EXISTS (SELECT 1 FROM dbo.Users)
BEGIN
    -- 1. Seed Users (2 Customers + 2 Repair Shop Owners)
    INSERT INTO dbo.Users (full_name, email, phone, password_hash, role)
    VALUES
        (N'Aarav Sharma',    N'aarav.customer@example.com',  '9841000001', N'$2b$10$hashedpasswordcustomer1', 'Customer'),
        (N'Priya Thapa',     N'priya.customer@example.com',  '9841000002', N'$2b$10$hashedpasswordcustomer2', 'Customer'),
        (N'Ramesh Adhikari', N'ramesh.shop@example.com',     '9851000001', N'$2b$10$hashedpasswordbusiness1', 'Business'),
        (N'Sita Gurung',     N'sita.shop@example.com',       '9851000002', N'$2b$10$hashedpasswordbusiness2', 'Business');

    -- 2. Seed Shops (Linked to Business Users 3 and 4)
    INSERT INTO dbo.Shops (owner_user_id, shop_name, address, specialization, contact_phone, opening_hours, supported_devices)
    VALUES
        (3, N'Kathmandu QuickFix Electronics', N'Putalisadak, Kathmandu', N'Smartphones & Laptops', '01-4221100', N'Sun-Fri 9:00 AM - 7:00 PM', N'Smartphone, Laptop, Tablet'),
        (4, N'Patan TechCare Lab',             N'Pulchowk, Lalitpur',     N'Motherboard & Gaming Consoles', '01-5523344', N'Sun-Fri 10:00 AM - 6:30 PM', N'Laptop, Console, Desktop');

    -- 3. Seed 3 Requests at Different Lifecycle Stages
    -- Request 1: Active Booking (In 'Repairing' stage)
    INSERT INTO dbo.Requests (reference_number, customer_id, shop_id, device_type, device_model, problem_description, request_status)
    VALUES ('FIX-20261125-1001', 1, 1, N'Smartphone', N'iPhone 14 Pro', N'Cracked OLED screen and fast battery drain.', 'Accepted');

    INSERT INTO dbo.Estimates (request_id, estimated_cost, estimated_completion_time, business_notes, estimate_status)
    VALUES (1, 18500.00, N'2 Business Days', N'Original display assembly + battery replacement included.', 'Accepted');

    INSERT INTO dbo.Bookings (request_id, estimate_id, current_repair_status)
    VALUES (1, 1, 'Repairing');

    INSERT INTO dbo.Repair_Status_History (booking_id, status, remarks)
    VALUES
        (1, 'Received',   N'Device dropped off at Putalisadak counter.'),
        (1, 'Diagnosing', N'Confirmed OLED digitizer damage and 76% battery health.'),
        (1, 'Repairing',  N'New display module installed; running battery calibration.');

    -- Request 2: Estimate Sent (Waiting for Customer Approval)
    INSERT INTO dbo.Requests (reference_number, customer_id, shop_id, device_type, device_model, problem_description, request_status)
    VALUES ('FIX-20261125-1002', 2, 1, N'Laptop', N'Dell XPS 13 9310', N'USB-C charging port loose and overheating under load.', 'Accepted');

    INSERT INTO dbo.Estimates (request_id, estimated_cost, estimated_completion_time, business_notes, estimate_status)
    VALUES (2, 6500.00, N'1-2 Days', N'Includes USB-C daughterboard replacement and thermal paste repasting.', 'Sent');

    -- Request 3: Brand New Pending Request (Waiting for Shop Review)
    INSERT INTO dbo.Requests (reference_number, customer_id, shop_id, device_type, device_model, problem_description, request_status)
    VALUES ('FIX-20261125-1003', 1, 2, N'Console', N'PlayStation 5', N'HDMI port bent, no video output on TV.', 'Pending');

    -- 4. Seed Notifications
    INSERT INTO dbo.Notifications (user_id, request_id, message, is_read)
    VALUES
        (1, 1, N'Repair status for FIX-20261125-1001 updated to: Repairing.', 0),
        (2, 2, N'You received a repair estimate of 6500.00 for request FIX-20261125-1002.', 0),
        (4, 3, N'New repair request (FIX-20261125-1003) received for PlayStation 5.', 0);

    PRINT 'Sample seed data inserted successfully.';
END
ELSE
BEGIN
    PRINT 'Database already contains data. Skipping seed.';
END
GO