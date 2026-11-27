const { sql, getPool } = require('../config/database');

const userRepository = {
  async findByEmail(email) {
    const pool = await getPool();
    const result = await pool
      .request()
      .input('email', sql.NVarChar(120), email)
      .query(`
        SELECT user_id, full_name, email, phone, password_hash, role, created_at
        FROM dbo.Users
        WHERE email = @email
      `);
    return result.recordset[0] || null;
  },

  async findById(userId) {
    const pool = await getPool();
    const result = await pool
      .request()
      .input('userId', sql.Int, userId)
      .query(`
        SELECT user_id, full_name, email, phone, role, created_at
        FROM dbo.Users
        WHERE user_id = @userId
      `);
    return result.recordset[0] || null;
  },

  async create({ fullName, email, phone, passwordHash, role }) {
    const pool = await getPool();
    const result = await pool
      .request()
      .input('fullName', sql.NVarChar(100), fullName)
      .input('email', sql.NVarChar(120), email)
      .input('phone', sql.VarChar(20), phone)
      .input('passwordHash', sql.NVarChar(255), passwordHash)
      .input('role', sql.VarChar(20), role)
      .query(`
        INSERT INTO dbo.Users (full_name, email, phone, password_hash, role)
        OUTPUT INSERTED.user_id, INSERTED.full_name, INSERTED.email, INSERTED.phone, INSERTED.role, INSERTED.created_at
        VALUES (@fullName, @email, @phone, @passwordHash, @role)
      `);
    return result.recordset[0];
  }
};

module.exports = userRepository;