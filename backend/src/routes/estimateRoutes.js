const express = require('express');
const estimateController = require('../controllers/estimateController');
const { authenticate, authorizeRoles } = require('../middleware/authMiddleware');
const { USER_ROLES } = require('../models/constants');

const router = express.Router();

router.post('/', authenticate, authorizeRoles(USER_ROLES.BUSINESS), estimateController.createEstimate);
router.get('/request/:requestId', authenticate, estimateController.getEstimateByRequestId);
router.patch('/:id/respond', authenticate, authorizeRoles(USER_ROLES.CUSTOMER), estimateController.respondToEstimate);

module.exports = router;