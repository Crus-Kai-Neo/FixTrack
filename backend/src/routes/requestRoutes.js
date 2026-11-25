const express = require('express');
const requestController = require('../controllers/requestController');
const { authenticate, authorizeRoles } = require('../middleware/authMiddleware');
const { USER_ROLES } = require('../models/constants');

const router = express.Router();

router.post('/', authenticate, authorizeRoles(USER_ROLES.CUSTOMER), requestController.createRequest);
router.get('/my-requests', authenticate, authorizeRoles(USER_ROLES.CUSTOMER), requestController.getMyRequests);
router.get('/shop/:shopId', authenticate, authorizeRoles(USER_ROLES.BUSINESS), requestController.getShopRequests);
router.get('/:id', authenticate, requestController.getRequestById);
router.patch('/:id/status', authenticate, authorizeRoles(USER_ROLES.BUSINESS), requestController.updateRequestStatus);

module.exports = router;