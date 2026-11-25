const express = require('express');
const bookingController = require('../controllers/bookingController');
const { authenticate, authorizeRoles } = require('../middleware/authMiddleware');
const { USER_ROLES } = require('../models/constants');

const router = express.Router();

router.get('/my-bookings', authenticate, authorizeRoles(USER_ROLES.CUSTOMER), bookingController.getMyBookings);
router.get('/shop/:shopId', authenticate, authorizeRoles(USER_ROLES.BUSINESS), bookingController.getShopBookings);
router.get('/:id', authenticate, bookingController.getBookingById);
router.patch('/:id/status', authenticate, authorizeRoles(USER_ROLES.BUSINESS), bookingController.updateRepairStatus);

module.exports = router;