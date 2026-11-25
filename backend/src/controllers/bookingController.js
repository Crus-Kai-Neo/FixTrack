const bookingService = require('../services/bookingService');

const bookingController = {
  async getMyBookings(req, res, next) {
    try {
      const bookings = await bookingService.getCustomerBookings(req.user.userId);
      res.status(200).json({
        success: true,
        message: 'Your bookings retrieved successfully',
        data: bookings
      });
    } catch (error) {
      next(error);
    }
  },

  async getShopBookings(req, res, next) {
    try {
      const shopId = parseInt(req.params.shopId, 10);
      if (Number.isNaN(shopId)) {
        return res.status(400).json({
          success: false,
          message: 'Invalid shop ID.'
        });
      }

      const bookings = await bookingService.getShopBookings(shopId, req.user.userId);
      res.status(200).json({
        success: true,
        message: 'Shop bookings retrieved successfully',
        data: bookings
      });
    } catch (error) {
      next(error);
    }
  },

  async getBookingById(req, res, next) {
    try {
      const bookingId = parseInt(req.params.id, 10);
      if (Number.isNaN(bookingId)) {
        return res.status(400).json({
          success: false,
          message: 'Invalid booking ID.'
        });
      }

      const booking = await bookingService.getBookingById(bookingId, req.user);
      res.status(200).json({
        success: true,
        message: 'Booking retrieved successfully',
        data: booking
      });
    } catch (error) {
      next(error);
    }
  },

  async updateRepairStatus(req, res, next) {
    try {
      const bookingId = parseInt(req.params.id, 10);
      const { repair_status, remarks } = req.body;

      if (Number.isNaN(bookingId)) {
        return res.status(400).json({
          success: false,
          message: 'Invalid booking ID.'
        });
      }

      if (!repair_status) {
        return res.status(400).json({
          success: false,
          message: 'repair_status is required.'
        });
      }

      const updatedBooking = await bookingService.updateRepairStatus(
        bookingId,
        req.user.userId,
        { repair_status, remarks }
      );

      res.status(200).json({
        success: true,
        message: `Repair status updated to '${repair_status}' successfully`,
        data: updatedBooking
      });
    } catch (error) {
      next(error);
    }
  }
};

module.exports = bookingController;