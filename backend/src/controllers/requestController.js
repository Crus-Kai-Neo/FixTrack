const requestService = require('../services/requestService');

const requestController = {
  async createRequest(req, res, next) {
    try {
      const { shop_id, device_type, device_model, problem_description } = req.body;

      if (!shop_id || !device_type || !device_model || !problem_description) {
        return res.status(400).json({
          success: false,
          message: 'shop_id, device_type, device_model, and problem_description are required.'
        });
      }

      const parsedShopId = parseInt(shop_id, 10);
      if (Number.isNaN(parsedShopId)) {
        return res.status(400).json({
          success: false,
          message: 'Invalid shop_id.'
        });
      }

      const createdRequest = await requestService.createRequest(req.user.userId, {
        shop_id: parsedShopId,
        device_type,
        device_model,
        problem_description
      });

      res.status(201).json({
        success: true,
        message: 'Repair request submitted successfully',
        data: createdRequest
      });
    } catch (error) {
      next(error);
    }
  },

  async getMyRequests(req, res, next) {
    try {
      const requests = await requestService.getCustomerRequests(req.user.userId);
      res.status(200).json({
        success: true,
        message: 'Your repair requests retrieved successfully',
        data: requests
      });
    } catch (error) {
      next(error);
    }
  },

  async getShopRequests(req, res, next) {
    try {
      const shopId = parseInt(req.params.shopId, 10);
      if (Number.isNaN(shopId)) {
        return res.status(400).json({
          success: false,
          message: 'Invalid shop ID.'
        });
      }

      const requests = await requestService.getShopRequests(shopId, req.user.userId);
      res.status(200).json({
        success: true,
        message: 'Shop repair requests retrieved successfully',
        data: requests
      });
    } catch (error) {
      next(error);
    }
  },

  async getRequestById(req, res, next) {
    try {
      const requestId = parseInt(req.params.id, 10);
      if (Number.isNaN(requestId)) {
        return res.status(400).json({
          success: false,
          message: 'Invalid request ID.'
        });
      }

      const request = await requestService.getRequestById(requestId, req.user);
      res.status(200).json({
        success: true,
        message: 'Repair request retrieved successfully',
        data: request
      });
    } catch (error) {
      next(error);
    }
  },

  async updateRequestStatus(req, res, next) {
    try {
      const requestId = parseInt(req.params.id, 10);
      const { request_status } = req.body;

      if (Number.isNaN(requestId)) {
        return res.status(400).json({
          success: false,
          message: 'Invalid request ID.'
        });
      }

      if (!request_status) {
        return res.status(400).json({
          success: false,
          message: 'request_status is required (Accepted or Rejected).'
        });
      }

      const updated = await requestService.updateRequestStatus(
        requestId,
        req.user.userId,
        request_status
      );

      res.status(200).json({
        success: true,
        message: `Repair request ${request_status.toLowerCase()} successfully`,
        data: updated
      });
    } catch (error) {
      next(error);
    }
  }
};

module.exports = requestController;