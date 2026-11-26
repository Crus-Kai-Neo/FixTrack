const { requestRepository, shopRepository } = require('../repositories');

const dashboardController = {
  async getCustomerDashboard(req, res, next) {
    try {
      const items = await requestRepository.findByCustomerId(req.user.userId);

      const summary = {
        total_requests: items.length,
        pending_requests: items.filter((i) => i.request_status === 'Pending').length,
        awaiting_estimate_approval: items.filter((i) => i.estimate_status === 'Sent').length,
        active_repairs: items.filter(
          (i) => i.booking_id && i.current_repair_status !== 'Collected'
        ).length,
        completed_repairs: items.filter((i) => i.current_repair_status === 'Collected').length
      };

      res.status(200).json({
        success: true,
        message: 'Customer dashboard retrieved successfully',
        data: { summary, items }
      });
    } catch (error) {
      next(error);
    }
  },

  async getShopDashboard(req, res, next) {
    try {
      const shopId = parseInt(req.params.shopId, 10);
      if (Number.isNaN(shopId)) {
        return res.status(400).json({
          success: false,
          message: 'Invalid shop ID.'
        });
      }

      const shop = await shopRepository.findById(shopId);
      if (!shop) {
        return res.status(404).json({
          success: false,
          message: 'Repair shop not found.'
        });
      }

      if (shop.owner_user_id !== req.user.userId) {
        return res.status(403).json({
          success: false,
          message: 'Access denied. You can only view the dashboard for your own shop.'
        });
      }

      const items = await requestRepository.findByShopId(shopId);

      const summary = {
        total_requests: items.length,
        new_pending_requests: items.filter((i) => i.request_status === 'Pending').length,
        sent_estimates: items.filter((i) => i.estimate_status === 'Sent').length,
        active_bookings: items.filter(
          (i) => i.booking_id && i.current_repair_status !== 'Collected'
        ).length,
        collected_repairs: items.filter((i) => i.current_repair_status === 'Collected').length
      };

      res.status(200).json({
        success: true,
        message: 'Shop dashboard retrieved successfully',
        data: { shop, summary, items }
      });
    } catch (error) {
      next(error);
    }
  }
};

module.exports = dashboardController;