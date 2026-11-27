const {
  bookingRepository,
  shopRepository
} = require('../repositories');
const { REPAIR_STATUS, REPAIR_STATUS_FLOW } = require('../models/constants');

const bookingService = {
  async getCustomerBookings(customerId) {
    return bookingRepository.findByCustomerId(customerId);
  },

  async getShopBookings(shopId, ownerUserId) {
    const shop = await shopRepository.findById(shopId);
    if (!shop) {
      const error = new Error('Repair shop not found.');
      error.status = 404;
      throw error;
    }

    if (shop.owner_user_id !== ownerUserId) {
      const error = new Error('Access denied. You can only view bookings for your own shop.');
      error.status = 403;
      throw error;
    }

    return bookingRepository.findByShopId(shopId);
  },

  async getBookingById(bookingId, user) {
    const booking = await bookingRepository.findById(bookingId);
    if (!booking) {
      const error = new Error('Booking not found.');
      error.status = 404;
      throw error;
    }

    const isCustomerOwner = booking.customer_id === user.userId;
    const isShopOwner = booking.shop_owner_id === user.userId;

    if (!isCustomerOwner && !isShopOwner) {
      const error = new Error('Access denied. You do not have permission to view this booking.');
      error.status = 403;
      throw error;
    }

    const statusHistory = await bookingRepository.getStatusHistory(bookingId);

    return {
      ...booking,
      status_history: statusHistory
    };
  },

  async updateRepairStatus(bookingId, ownerUserId, { repair_status, remarks }) {
    if (!REPAIR_STATUS_FLOW.includes(repair_status)) {
      const error = new Error(
        `Invalid repair_status. Must be one of: ${REPAIR_STATUS_FLOW.join(', ')}`
      );
      error.status = 400;
      throw error;
    }

    const booking = await bookingRepository.findById(bookingId);
    if (!booking) {
      const error = new Error('Booking not found.');
      error.status = 404;
      throw error;
    }

    if (booking.shop_owner_id !== ownerUserId) {
      const error = new Error('Access denied. Only the shop owner can update repair status.');
      error.status = 403;
      throw error;
    }

    if (booking.current_repair_status === REPAIR_STATUS.COLLECTED) {
      const error = new Error('This booking is already marked as Collected.');
      error.status = 400;
      throw error;
    }

    const updatedBooking = await bookingRepository.updateStatusWithHistory(
      bookingId,
      repair_status,
      remarks ? remarks.trim() : `Status updated to ${repair_status}.`
    );

    const statusHistory = await bookingRepository.getStatusHistory(bookingId);

    return {
      ...updatedBooking,
      status_history: statusHistory
    };
  }
};

module.exports = bookingService;