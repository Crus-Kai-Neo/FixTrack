const { sql, getPool } = require('../config/database');

const shopRepository = {
  async findAll({ search = '', specialization = '' } = {}) {
    const pool = await getPool();
    const request = pool.request();
    const conditions = [];

    if (search) {
      request.input('search', sql.NVarChar(200), `%${search}%`);
      conditions.push('(s.shop_name LIKE @search OR s.address LIKE @search OR s.supported_devices LIKE @search)');
    }

    if (specialization) {
      request.input('specialization', sql.NVarChar(200), `%${specialization}%`);
      conditions.push('s.specialization LIKE @specialization');
    }

    const whereClause = conditions.length > 0 ? `WHERE ${conditions.join(' AND ')}` : '';

    const result = await request.query(`
      SELECT
        s.shop_id,
        s.owner_user_id,
        u.full_name AS owner_name,
        s.shop_name,
        s.address,
        s.specialization,
        s.contact_phone,
        s.opening_hours,
        s.supported_devices,
        s.created_at
      FROM dbo.Shops s
      INNER JOIN dbo.Users u ON s.owner_user_id = u.user_id
      ${whereClause}
      ORDER BY s.created_at DESC
    `);
    return result.recordset;
  },

  async findById(shopId) {
    const pool = await getPool();
    const result = await pool
      .request()
      .input('shopId', sql.Int, shopId)
      .query(`
        SELECT
          s.shop_id,
          s.owner_user_id,
          u.full_name AS owner_name,
          s.shop_name,
          s.address,
          s.specialization,
          s.contact_phone,
          s.opening_hours,
          s.supported_devices,
          s.created_at
        FROM dbo.Shops s
        INNER JOIN dbo.Users u ON s.owner_user_id = u.user_id
        WHERE s.shop_id = @shopId
      `);
    return result.recordset[0] || null;
  },

  async findByOwnerId(ownerUserId) {
    const pool = await getPool();
    const result = await pool
      .request()
      .input('ownerUserId', sql.Int, ownerUserId)
      .query(`
        SELECT shop_id, owner_user_id, shop_name, address, specialization, contact_phone, opening_hours, supported_devices, created_at
        FROM dbo.Shops
        WHERE owner_user_id = @ownerUserId
      `);
    return result.recordset;
  },

  async create({ ownerUserId, shopName, address, specialization, contactPhone, openingHours, supportedDevices }) {
    const pool = await getPool();
    const result = await pool
      .request()
      .input('ownerUserId', sql.Int, ownerUserId)
      .input('shopName', sql.NVarChar(120), shopName)
      .input('address', sql.NVarChar(200), address)
      .input('specialization', sql.NVarChar(200), specialization || null)
      .input('contactPhone', sql.VarChar(20), contactPhone)
      .input('openingHours', sql.NVarChar(80), openingHours || null)
      .input('supportedDevices', sql.NVarChar(200), supportedDevices || null)
      .query(`
        INSERT INTO dbo.Shops (owner_user_id, shop_name, address, specialization, contact_phone, opening_hours, supported_devices)
        OUTPUT INSERTED.*
        VALUES (@ownerUserId, @shopName, @address, @specialization, @contactPhone, @openingHours, @supportedDevices)
      `);
    return result.recordset[0];
  },

  async update(shopId, { shopName, address, specialization, contactPhone, openingHours, supportedDevices }) {
    const pool = await getPool();
    const result = await pool
      .request()
      .input('shopId', sql.Int, shopId)
      .input('shopName', sql.NVarChar(120), shopName)
      .input('address', sql.NVarChar(200), address)
      .input('specialization', sql.NVarChar(200), specialization || null)
      .input('contactPhone', sql.VarChar(20), contactPhone)
      .input('openingHours', sql.NVarChar(80), openingHours || null)
      .input('supportedDevices', sql.NVarChar(200), supportedDevices || null)
      .query(`
        UPDATE dbo.Shops
        SET
          shop_name = @shopName,
          address = @address,
          specialization = @specialization,
          contact_phone = @contactPhone,
          opening_hours = @openingHours,
          supported_devices = @supportedDevices
        OUTPUT INSERTED.*
        WHERE shop_id = @shopId
      `);
    return result.recordset[0] || null;
  }
};

module.exports = shopRepository;