const { sql, getPool } = require('../config/database');

const requestRepository = {
  async create({ referenceNumber, customerId, shopId, deviceType, deviceModel, problemDescription }) {
    const pool = await getPool();
    const result = await pool
      .request()
      .input('referenceNumber', sql.VarChar(25), referenceNumber)
      .input('customerId', sql.Int, customerId)
      .input('shopId', sql.Int, shopId)
      .input('deviceType', sql.NVarChar(50), deviceType)
      .input('deviceModel', sql.NVarChar(100), deviceModel)
      .input('problemDescription', sql.NVarChar(sql.MAX), problemDescription)
      .query(`
        INSERT INTO dbo.Requests (reference_number, customer_id, shop_id, device_type, device_model, problem_description)
        OUTPUT INSERTED.*
        VALUES (@referenceNumber, @customerId, @shopId, @deviceType, @deviceModel, @problemDescription)
      `);
    return result.recordset[0];
  },

  async findById(requestId) {
    const pool = await getPool();
    const result = await pool
      .request()
      .input('requestId', sql.Int, requestId)
      .query(`
        SELECT
          r.*,
          c.full_name AS customer_name,
          c.phone AS customer_phone,
          s.shop_name,
          s.owner_user_id AS shop_owner_id,
          e.estimate_id,
          e.estimated_cost,
          e.estimated_completion_time,
          e.business_notes,
          e.estimate_status,
          e.sent_at,
          b.booking_id,
          b.current_repair_status,
          b.confirmed_at
        FROM dbo.Requests r
        INNER JOIN dbo.Users c ON r.customer_id = c.user_id
        INNER JOIN dbo.Shops s ON r.shop_id = s.shop_id
        LEFT JOIN dbo.Estimates e ON r.request_id = e.request_id
        LEFT JOIN dbo.Bookings b ON r.request_id = b.request_id
        WHERE r.request_id = @requestId
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
          r.*,
          s.shop_name,
          s.address AS shop_address,
          e.estimate_id,
          e.estimated_cost,
          e.estimated_completion_time,
          e.estimate_status,
          b.booking_id,
          b.current_repair_status
        FROM dbo.Requests r
        INNER JOIN dbo.Shops s ON r.shop_id = s.shop_id
        LEFT JOIN dbo.Estimates e ON r.request_id = e.request_id
        LEFT JOIN dbo.Bookings b ON r.request_id = b.request_id
        WHERE r.customer_id = @customerId
        ORDER BY r.created_at DESC
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
          r.*,
          c.full_name AS customer_name,
          c.phone AS customer_phone,
          e.estimate_id,
          e.estimated_cost,
          e.estimate_status,
          b.booking_id,
          b.current_repair_status
        FROM dbo.Requests r
        INNER JOIN dbo.Users c ON r.customer_id = c.user_id
        LEFT JOIN dbo.Estimates e ON r.request_id = e.request_id
        LEFT JOIN dbo.Bookings b ON r.request_id = b.request_id
        WHERE r.shop_id = @shopId
        ORDER BY r.created_at DESC
      `);
    return result.recordset;
  },

  async updateStatus(requestId, status) {
    const pool = await getPool();
    const result = await pool
      .request()
      .input('requestId', sql.Int, requestId)
      .input('status', sql.VarChar(25), status)
      .query(`
        UPDATE dbo.Requests
        SET request_status = @status
        OUTPUT INSERTED.*
        WHERE request_id = @requestId
      `);
    return result.recordset[0] || null;
  }
};

module.exports = requestRepository;