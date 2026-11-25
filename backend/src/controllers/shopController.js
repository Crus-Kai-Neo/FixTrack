const shopService = require('../services/shopService');

const shopController = {
  async listShops(req, res, next) {
    try {
      const { search, specialization } = req.query;
      const shops = await shopService.listShops({ search, specialization });

      res.status(200).json({
        success: true,
        message: 'Repair shops retrieved successfully',
        data: shops
      });
    } catch (error) {
      next(error);
    }
  },

  async getMyShops(req, res, next) {
    try {
      const shops = await shopService.getMyShops(req.user.userId);

      res.status(200).json({
        success: true,
        message: 'Your repair shops retrieved successfully',
        data: shops
      });
    } catch (error) {
      next(error);
    }
  },

  async getShopById(req, res, next) {
    try {
      const shopId = parseInt(req.params.id, 10);
      if (Number.isNaN(shopId)) {
        return res.status(400).json({
          success: false,
          message: 'Invalid shop ID.'
        });
      }

      const shop = await shopService.getShopById(shopId);

      res.status(200).json({
        success: true,
        message: 'Repair shop retrieved successfully',
        data: shop
      });
    } catch (error) {
      next(error);
    }
  },

  async createShop(req, res, next) {
    try {
      const { shop_name, address, contact_phone } = req.body;

      if (!shop_name || !address || !contact_phone) {
        return res.status(400).json({
          success: false,
          message: 'shop_name, address, and contact_phone are required.'
        });
      }

      const shop = await shopService.createShop(req.user.userId, req.body);

      res.status(201).json({
        success: true,
        message: 'Repair shop created successfully',
        data: shop
      });
    } catch (error) {
      next(error);
    }
  },

  async updateShop(req, res, next) {
    try {
      const shopId = parseInt(req.params.id, 10);
      if (Number.isNaN(shopId)) {
        return res.status(400).json({
          success: false,
          message: 'Invalid shop ID.'
        });
      }

      const updatedShop = await shopService.updateShop(shopId, req.user.userId, req.body);

      res.status(200).json({
        success: true,
        message: 'Repair shop updated successfully',
        data: updatedShop
      });
    } catch (error) {
      next(error);
    }
  }
};

module.exports = shopController;