const express = require('express');
const shopController = require('../controllers/shopController');
const { authenticate, authorizeRoles } = require('../middleware/authMiddleware');
const { USER_ROLES } = require('../models/constants');

const router = express.Router();

router.get('/', shopController.listShops);
router.get('/my-shops', authenticate, authorizeRoles(USER_ROLES.BUSINESS), shopController.getMyShops);
router.get('/:id', shopController.getShopById);
router.post('/', authenticate, authorizeRoles(USER_ROLES.BUSINESS), shopController.createShop);
router.put('/:id', authenticate, authorizeRoles(USER_ROLES.BUSINESS), shopController.updateShop);

module.exports = router;