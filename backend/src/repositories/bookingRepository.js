const { sql, getPool } = require('../config/database');

const bookingRepository = {
  async findById(bookingId) {
    const pool = await getPool();
    const result = await pool
      .request()
      .input('bookingId', sql.Int, bookingId)
      .query(`
        SELECT
          b.*,
          r.reference_number,
          r.customer_id,
          r.shop_id,
          r.device_type,
          r.device_model,
          r.problem_description,
          c.full_name AS customer_name,
          c.phone AS customer_phone,
          s.shop_name,
          s.owner_user_id AS shop_owner_id,
          e.estimated_cost,
          e.estimated_completion_time
        FROM dbo.Bookings b
        INNER JOIN dbo.Requests r ON b.request_id = r.request_id
        INNER JOIN dbo.Users c ON r.customer_id = c.user_id
        INNER JOIN dbo.Shops s ON r.shop_id = s.shop_id
        INNER JOIN dbo.Estimates e ON b.estimate_id = e.estimate_id
        WHERE b.booking_id = @bookingId
      `);
    return result.recordset[0] || null;
  },

  async findByCustomerId(customerId) {
    const pool = await getPool();
    const result = await pool
      .request()
      .input('customerId', sql.Int, customerId)
      .query(`
        SELECT
          b.*,
          r.reference_number,
          r.device_type,
          r.device_model,
          s.shop_name,
          e.estimated_cost,
          e.estimated_completion_time
        FROM dbo.Bookings b
        INNER JOIN dbo.Requests r ON b.request_id = r.request_id
        INNER JOIN dbo.Shops s ON r.shop_id = s.shop_id
        INNER JOIN dbo.Estimates e ON b.estimate_id = e.estimate_id
        WHERE r.customer_id = @customerId
        ORDER BY b.confirmed_at DESC
      `);
    return result.recordset;
  },

  async findByShopId(shopId) {
    const pool = await getPool();
    const result = await pool
      .request()
      .input('shopId', sql.Int, shopId)
      .query(`
        SELECT
          b.*,
          r.reference_number,
          r.device_type,
          r.device_model,
          c.full_name AS customer_name,
          c.phone AS customer_phone,
          e.estimated_cost,
          e.estimated_completion_time
        FROM dbo.Bookings b
        INNER JOIN dbo.Requests r ON b.request_id = r.request_id
        INNER JOIN dbo.Users c ON r.customer_id = c.user_id
        INNER JOIN dbo.Estimates e ON b.estimate_id = e.estimate_id
        WHERE r.shop_id = @shopId
        ORDER BY b.confirmed_at DESC
      `);
    return result.recordset;
  },

  async updateStatusWithHistory(bookingId, status, remarks = null) {
    const pool = await getPool();
    await pool
      .request()
      .input('booking_id', sql.Int, bookingId)
      .input('new_status', sql.VarChar(20), status)
      .input('remarks', sql.NVarChar(300), remarks)
      .execute('dbo.sp_UpdateRepairStatus');

    return this.findById(bookingId);
  },

  async getStatusHistory(bookingId) {
    const pool = await getPool();
    const result = await pool
      .request()
      .input('bookingId', sql.Int, bookingId)
      .query(`
        SELECT history_id, booking_id, status, remarks, updated_at
        FROM dbo.Repair_Status_History
        WHERE booking_id = @bookingId
        ORDER BY updated_at ASC, history_id ASC
      `);
    return result.recordset;
  }
};

module.exports = bookingRepository;