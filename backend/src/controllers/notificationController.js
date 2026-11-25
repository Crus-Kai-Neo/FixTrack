const notificationService = require('../services/notificationService');

const notificationController = {
  async getMyNotifications(req, res, next) {
    try {
      const data = await notificationService.getUserNotifications(req.user.userId);
      res.status(200).json({
        success: true,
        message: 'Notifications retrieved successfully',
        data
      });
    } catch (error) {
      next(error);
    }
  },

  async markAsRead(req, res, next) {
    try {
      const notificationId = parseInt(req.params.id, 10);
      if (Number.isNaN(notificationId)) {
        return res.status(400).json({
          success: false,
          message: 'Invalid notification ID.'
        });
      }

      const updated = await notificationService.markNotificationAsRead(
        notificationId,
        req.user.userId
      );

      res.status(200).json({
        success: true,
        message: 'Notification marked as read',
        data: updated
      });
    } catch (error) {
      next(error);
    }
  },

  async markAllAsRead(req, res, next) {
    try {
      await notificationService.markAllNotificationsAsRead(req.user.userId);
      res.status(200).json({
        success: true,
        message: 'All notifications marked as read'
      });
    } catch (error) {
      next(error);
    }
  }
};

module.exports = notificationController;