const { sql, getPool } = require('../config/database');

const notificationRepository = {
  async create({ userId, requestId = null, message }) {
    const pool = await getPool();
    const result = await pool
      .request()
      .input('userId', sql.Int, userId)
      .input('requestId', sql.Int, requestId)
      .input('message', sql.NVarChar(255), message)
      .query(`
        INSERT INTO dbo.Notifications (user_id, request_id, message)
        OUTPUT INSERTED.*
        VALUES (@userId, @requestId, @message)
      `);
    return result.recordset[0];
  },

  async findByUserId(userId) {
    const pool = await getPool();
    const result = await pool
      .request()
      .input('userId', sql.Int, userId)
      .query(`
        SELECT notification_id, user_id, request_id, message, is_read, created_at
        FROM dbo.Notifications
        WHERE user_id = @userId
        ORDER BY created_at DESC
      `);
    return result.recordset;
  },

  async markAsRead(notificationId, userId) {
    const pool = await getPool();
    const result = await pool
      .request()
      .input('notificationId', sql.Int, notificationId)
      .input('userId', sql.Int, userId)
      .query(`
        UPDATE dbo.Notifications
        SET is_read = 1
        OUTPUT INSERTED.*
        WHERE notification_id = @notificationId AND user_id = @userId
      `);
    return result.recordset[0] || null;
  },

  async markAllAsRead(userId) {
    const pool = await getPool();
    await pool
      .request()
      .input('userId', sql.Int, userId)
      .query(`
        UPDATE dbo.Notifications
        SET is_read = 1
        WHERE user_id = @userId AND is_read = 0
      `);
  }
};

module.exports = notificationRepository;