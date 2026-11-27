# FixTrack Backend (Node.js / Express) Database Contract

## 1. Connection Credentials (`.env`)
Add these variables to the Node.js backend `.env` file:

```env
DB_SERVER=localhost
DB_INSTANCE=SQLEXPRESS
DB_PORT=1433
DB_NAME=FixTrackDB
DB_USER=fixtrack_api
DB_PASSWORD=FixTrack@2026!
DB_ENCRYPT=false
DB_TRUST_SERVER_CERTIFICATE=true

2. Read Views (Use for GET Endpoints)View NamePurposeFilter Columndbo.vw_CustomerRepairDashboardFetches all requests, shop info, quotes, and live repair statuses for a customerWHERE customer_id = @customer_iddbo.vw_ShopRepairDashboardFetches incoming requests, customer contact details, quotes, and active bookings for a shopWHERE shop_id = @shop_id (or owner_user_id = @user_id)3. Transactional Stored Procedures (Use for POST / PATCH Endpoints)Stored ProcedureInput ParametersAtomic Actions PerformedReturnsdbo.sp_CreateRepairRequest@customer_id, @shop_id, @device_type, @device_model, @problem_descriptionGenerates FIX-YYYYMMDD-XXXX reference number, inserts into Requests, and notifies the shop ownerrequest_id, reference_numberdbo.sp_SendEstimate@request_id, @estimated_cost, @estimated_completion_time, @business_notes (optional)Sets Requests.request_status = 'Accepted', inserts into Estimates, and notifies the customerestimate_iddbo.sp_AcceptEstimate@estimate_idSets Estimates.estimate_status = 'Accepted', creates a Bookings row (Received), logs initial Repair_Status_History, and notifies the shopbooking_iddbo.sp_UpdateRepairStatus@booking_id, @new_status, @remarks (optional)Updates Bookings.current_repair_status, appends to Repair_Status_History, and notifies the customerNone4. Allowed CHECK Constraint ValuesUsers.role: 'Customer', 'Business'Requests.request_status: 'Pending', 'Accepted', 'Rejected'Estimates.estimate_status: 'Sent', 'Accepted', 'Rejected'Bookings.current_repair_status & Repair_Status_History.status: 'Received', 'Diagnosing', 'Repairing', 'Ready', 'Collected'
---

### How to Create & Save It in 30 Seconds
1. Open **`E:\FixTrack\FixTrack\database\docs\`** in Windows File Explorer (or open VS Code).
2. Right-click inside the folder $\rightarrow$ **New** $\rightarrow$ **Text Document**, and name it **`BACKEND_API_CONTRACT.md`** (make sure it ends in `.md`, not `.md.txt`).
3. Open it in Notepad or VS Code, paste the block above, and press **`Ctrl + S`**.

<ElicitationsGroup message="Once you save BACKEND_API_CONTRACT.md:">
  <Elicitation label="Saved! What's next?" query="I saved BACKEND_API_CONTRACT.md in database/docs/. What should I do next?"/>
  <Elicitation label="Check my docs folder" query="I'm not sure if my file extension is .md or .md.txt. How do I check?"/>
</ElicitationsGroup>