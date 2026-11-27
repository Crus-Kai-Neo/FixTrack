# FixTrack Backend API

RESTful backend service for **FixTrack**, a repair-shop aggregator and live repair-tracking platform built with **Node.js**, **Express**, and **Microsoft SQL Server (`FixTrackDB`)**.

---

## Tech Stack

* **Runtime & Framework:** Node.js, Express.js
* **Database:** Microsoft SQL Server (`SQLEXPRESS`) via `mssql` (`tedious`)
* **Authentication:** JSON Web Tokens (`jsonwebtoken`) & `bcryptjs` password hashing
* **Architecture:** Layered MVC (`routes` → `controllers` → `services` → `repositories`) backed by SQL Server views and atomic transactional stored procedures

---

## Folder Structure

```text
backend/
├── src/
│   ├── config/          # SQL Server connection pool configuration
│   ├── controllers/     # HTTP request validation & response formatting
│   ├── middleware/      # JWT authentication, RBAC guards, global error handler
│   ├── models/          # Domain constants & allowed enum values
│   ├── repositories/    # Parameterized SQL queries, views, & stored procedure calls
│   ├── routes/          # Express route definitions
│   ├── services/        # Business logic & ownership authorization
│   └── app.js           # Express middleware & route mounting
├── .env.example         # Environment variable template
├── package.json
└── server.js            # Entry point
```

---

## Prerequisites

1. **Node.js** (v18 or higher)
2. **Microsoft SQL Server** (`SQLEXPRESS`) with:
    * **Mixed Mode Authentication** enabled
    * **TCP/IP** enabled on port **`1433`**
3. **FixTrackDB** initialized using the scripts in `../database/` (see `../database/docs/DATABASE_SETUP_AND_EXECUTION_ORDER.md`).

---

## Quick Start

1. **Navigate to the backend directory and install dependencies:**
   ```bash
   cd backend
   npm install
   ```

2. **Configure environment variables:**
   Copy `.env.example` to `.env` (or create `.env` in `backend/`) and fill in your credentials:
   ```env
   PORT=5000
   NODE_ENV=development

   DB_SERVER=localhost
   DB_INSTANCE=SQLEXPRESS
   DB_PORT=1433
   DB_NAME=FixTrackDB
   DB_USER=fixtrack_api
   DB_PASSWORD=FixTrack@2026!
   DB_ENCRYPT=false
   DB_TRUST_SERVER_CERTIFICATE=true

   JWT_SECRET=replace_with_a_strong_secret_key
   JWT_EXPIRES_IN=7d
   ```

3. **Start the development server:**
   ```bash
   npm run dev
   ```
   The API will start on **`http://localhost:5000`**.

4. **Verify health check:**
   ```bash
   curl http://localhost:5000/api/health
   ```

---

## Flutter Client Base URLs

* **Android Emulator:** `http://10.0.2.2:5000/api`
* **iOS Simulator / Web / Desktop:** `http://localhost:5000/api`

Include `Authorization: Bearer <token>` on all protected endpoints.

---

## API Endpoints Overview

### Health & Authentication
| Method | Endpoint | Access | Description |
| :--- | :--- | :--- | :--- |
| `GET` | `/api/health` | Public | Server health and environment status |
| `POST` | `/api/auth/register` | Public | Register a `Customer` or `Business` account |
| `POST` | `/api/auth/login` | Public | Authenticate user and receive JWT |
| `GET` | `/api/auth/me` | Authenticated | Get logged-in user profile |

### Repair Shops
| Method | Endpoint | Access | Description |
| :--- | :--- | :--- | :--- |
| `GET` | `/api/shops` | Public | List/search shops (`?search=...&specialization=...`) |
| `GET` | `/api/shops/my-shops` | `Business` | List shops owned by logged-in business |
| `GET` | `/api/shops/:id` | Public | Get single shop details |
| `POST` | `/api/shops` | `Business` | Create a new repair shop |
| `PUT` | `/api/shops/:id` | `Business` (Owner) | Update shop details |

### Repair Requests
| Method | Endpoint | Access | Description |
| :--- | :--- | :--- | :--- |
| `POST` | `/api/requests` | `Customer` | Submit request (`sp_CreateRepairRequest`) |
| `GET` | `/api/requests/my-requests` | `Customer` | List customer's requests (`vw_CustomerRepairDashboard`) |
| `GET` | `/api/requests/shop/:shopId` | `Business` (Owner) | List incoming shop requests (`vw_ShopRepairDashboard`) |
| `GET` | `/api/requests/:id` | Customer / Shop Owner | Get full request details |
| `PATCH` | `/api/requests/:id/status` | `Business` (Owner) | Accept or reject a pending request |

### Estimates & Quotes
| Method | Endpoint | Access | Description |
| :--- | :--- | :--- | :--- |
| `POST` | `/api/estimates` | `Business` (Owner) | Send cost/time estimate (`sp_SendEstimate`) |
| `GET` | `/api/estimates/request/:requestId` | Customer / Shop Owner | View estimate for a request |
| `PATCH` | `/api/estimates/:id/respond` | `Customer` (Owner) | Accept (`sp_AcceptEstimate` → creates booking) or reject estimate |

### Bookings & Repair Tracking
| Method | Endpoint | Access | Description |
| :--- | :--- | :--- | :--- |
| `GET` | `/api/bookings/my-bookings` | `Customer` | List customer's confirmed bookings |
| `GET` | `/api/bookings/shop/:shopId` | `Business` (Owner) | List shop's confirmed bookings |
| `GET` | `/api/bookings/:id` | Customer / Shop Owner | Get booking details + `status_history` timeline |
| `PATCH` | `/api/bookings/:id/status` | `Business` (Owner) | Update repair stage (`sp_UpdateRepairStatus`) |

### Dashboards & Notifications
| Method | Endpoint | Access | Description |
| :--- | :--- | :--- | :--- |
| `GET` | `/api/dashboard/customer` | `Customer` | Customer summary metrics + joined repair items |
| `GET` | `/api/dashboard/shop/:shopId` | `Business` (Owner) | Shop summary metrics + joined repair items |
| `GET` | `/api/notifications` | Authenticated | Fetch user notifications & `unread_count` |
| `PATCH` | `/api/notifications/:id/read` | Authenticated | Mark a notification as read |
| `PATCH` | `/api/notifications/read-all` | Authenticated | Mark all notifications as read |

---

## Allowed Enum Values

* **`role`:** `Customer`, `Business`
* **`request_status`:** `Pending`, `Accepted`, `Rejected`
* **`estimate_status`:** `Sent`, `Accepted`, `Rejected`
* **`repair_status`:** `Received`, `Diagnosing`, `Repairing`, `Ready`, `Collected`