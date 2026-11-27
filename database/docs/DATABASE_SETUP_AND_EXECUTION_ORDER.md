# FixTrack Database Setup & Execution Guide

## 1. Prerequisites
* **Database Engine:** Microsoft SQL Server (2019 / 2022 / 2025 Express or Developer Edition)
* **Management Tool:** SQL Server Management Studio (SSMS)
* **Server Configuration (Required for Node.js):**
  1. Enable **Mixed Mode Authentication** (SQL Server and Windows Authentication mode) in Server Properties $\rightarrow$ Security.
  2. Enable **TCP/IP** on static Port **`1433`]()** in SQL Server Configuration Manager $\rightarrow$ Protocols for `SQLEXPRESS` $\rightarrow$ IPAll.
  3. Restart the **SQL Server (`SQLEXPRESS`)** service.

## 2. Script Execution Order
Run the `.sql` scripts in SSMS in this exact sequence on a fresh machine:

1. `01_setup/01_create_database.sql` — Creates `FixTrackDB`
2. `01_setup/02_create_api_user.sql` — Creates the `fixtrack_api` login and database user
3. `02_schema/01_create_users.sql` — Creates `dbo.Users`
4. `02_schema/02_create_shops.sql` — Creates `dbo.Shops`
5. `02_schema/03_create_requests.sql` — Creates `dbo.Requests`
6. `02_schema/04_create_estimates.sql` — Creates `dbo.Estimates`
7. `02_schema/05_create_bookings.sql` — Creates `dbo.Bookings`
8. `02_schema/06_create_repair_status_history.sql` — Creates `dbo.Repair_Status_History`
9. `02_schema/07_create_notifications.sql` — Creates `dbo.Notifications`
10. `02_schema/08_create_indexes.sql` — Creates performance indexes
11. `03_programmability/views/01_views.sql` — Creates customer & shop dashboard views
12. `03_programmability/stored_procedures/01_sp_create_request.sql`
13. `03_programmability/stored_procedures/02_sp_send_estimate.sql`
14. `03_programmability/stored_procedures/03_sp_accept_estimate.sql`
15. `03_programmability/stored_procedures/04_sp_update_repair_status.sql`
16. `04_seed_data/01_seed_sample_data.sql` — Inserts sample users, shops, requests, estimates, bookings, and notifications

## 3. Resetting Test Data
To clear all test records and reset `IDENTITY` counters back to `1` without dropping tables or procedures, run:
* `05_reset_and_maintenance/01_reset_database.sql`
* Followed by `04_seed_data/01_seed_sample_data.sql`