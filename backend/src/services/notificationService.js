const { notificationRepository } = require('../repositories');

const notificationService = {
  async getUserNotifications(userId) {
    const notifications = await notificationRepository.findByUserId(userId);
    const unreadCount = notifications.filter((n) => !n.is_read).length;

    return {
      unread_count: unreadCount,
      notifications
    };
  },

  async markNotificationAsRead(notificationId, userId) {
    const updated = await notificationRepository.markAsRead(notificationId, userId);
    if (!updated) {
      const error = new Error('Notification not found or access denied.');
      error.status = 404;
      throw error;
    }
    return updated;
  },

  async markAllNotificationsAsRead(userId) {
    await notificationRepository.markAllAsRead(userId);
  }
};

module.exports = notificationService;