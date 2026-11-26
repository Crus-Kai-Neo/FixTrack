const express = require('express');
const dashboardController = require('../controllers/dashboardController');
const { authenticate, authorizeRoles } = require('../middleware/authMiddleware');
const { USER_ROLES } = require('../models/constants');

const router = express.Router();

router.get('/customer', authenticate, authorizeRoles(USER_ROLES.CUSTOMER), dashboardController.getCustomerDashboard);
router.get('/shop/:shopId', authenticate, authorizeRoles(USER_ROLES.BUSINESS), dashboardController.getShopDashboard);

module.exports = router;