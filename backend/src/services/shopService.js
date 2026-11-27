const { shopRepository } = require('../repositories');

const shopService = {
  async listShops({ search, specialization }) {
    return shopRepository.findAll({
      search: search ? search.trim() : '',
      specialization: specialization ? specialization.trim() : ''
    });
  },

  async getShopById(shopId) {
    const shop = await shopRepository.findById(shopId);
    if (!shop) {
      const error = new Error('Repair shop not found.');
      error.status = 404;
      throw error;
    }
    return shop;
  },

  async getMyShops(ownerUserId) {
    return shopRepository.findByOwnerId(ownerUserId);
  },

  async createShop(ownerUserId, payload) {
    return shopRepository.create({
      ownerUserId,
      shopName: payload.shop_name.trim(),
      address: payload.address.trim(),
      specialization: payload.specialization ? payload.specialization.trim() : null,
      contactPhone: payload.contact_phone.trim(),
      openingHours: payload.opening_hours ? payload.opening_hours.trim() : null,
      supportedDevices: payload.supported_devices ? payload.supported_devices.trim() : null
    });
  },

  async updateShop(shopId, ownerUserId, payload) {
    const existingShop = await shopRepository.findById(shopId);
    if (!existingShop) {
      const error = new Error('Repair shop not found.');
      error.status = 404;
      throw error;
    }

    if (existingShop.owner_user_id !== ownerUserId) {
      const error = new Error('Access denied. You can only update your own shop.');
      error.status = 403;
      throw error;
    }

    return shopRepository.update(shopId, {
      shopName: payload.shop_name ? payload.shop_name.trim() : existingShop.shop_name,
      address: payload.address ? payload.address.trim() : existingShop.address,
      specialization: payload.specialization !== undefined ? payload.specialization.trim() : existingShop.specialization,
      contactPhone: payload.contact_phone ? payload.contact_phone.trim() : existingShop.contact_phone,
      openingHours: payload.opening_hours !== undefined ? payload.opening_hours.trim() : existingShop.opening_hours,
      supportedDevices: payload.supported_devices !== undefined ? payload.supported_devices.trim() : existingShop.supported_devices
    });
  }
};

module.exports = shopService;