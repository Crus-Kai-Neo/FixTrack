const { sql, getPool } = require('../config/database');

const estimateRepository = {
  async create({ requestId, estimatedCost, estimatedCompletionTime, businessNotes }) {
    const pool = await getPool();
    const result = await pool
      .request()
      .input('requestId', sql.Int, requestId)
      .input('estimatedCost', sql.Decimal(10, 2), estimatedCost)
      .input('estimatedCompletionTime', sql.NVarChar(80), estimatedCompletionTime)
      .input('businessNotes', sql.NVarChar(500), businessNotes || null)
      .query(`
        INSERT INTO dbo.Estimates (request_id, estimated_cost, estimated_completion_time, business_notes)
        OUTPUT INSERTED.*
        VALUES (@requestId, @estimatedCost, @estimatedCompletionTime, @businessNotes)
      `);
    return result.recordset[0];
  },

  async findById(estimateId) {
    const pool = await getPool();
    const result = await pool
      .request()
      .input('estimateId', sql.Int, estimateId)
      .query(`
        SELECT e.*, r.customer_id, r.shop_id, r.reference_number, s.owner_user_id AS shop_owner_id
        FROM dbo.Estimates e
        INNER JOIN dbo.Requests r ON e.request_id = r.request_id
        INNER JOIN dbo.Shops s ON r.shop_id = s.shop_id
        WHERE e.estimate_id = @estimateId
      `);
    return result.recordset[0] || null;
  },

  async findByRequestId(requestId) {
    const pool = await getPool();
    const result = await pool
      .request()
      .input('requestId', sql.Int, requestId)
      .query(`
        SELECT *
        FROM dbo.Estimates
        WHERE request_id = @requestId
      `);
    return result.recordset[0] || null;
  },

  async updateStatus(estimateId, status) {
    const pool = await getPool();
    const result = await pool
      .request()
      .input('estimateId', sql.Int, estimateId)
      .input('status', sql.VarChar(25), status)
      .query(`
        UPDATE dbo.Estimates
        SET estimate_status = @status
        OUTPUT INSERTED.*
        WHERE estimate_id = @estimateId
      `);
    return result.recordset[0] || null;
  }
};

module.exports = estimateRepository;