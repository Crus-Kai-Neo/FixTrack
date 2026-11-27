const {
  requestRepository,
  shopRepository,
  notificationRepository
} = require('../repositories');
const { REQUEST_STATUS } = require('../models/constants');

const requestService = {
  async createRequest(customerId, { shop_id, device_type, device_model, problem_description }) {
    const shop = await shopRepository.findById(shop_id);
    if (!shop) {
      const error = new Error('Selected repair shop not found.');
      error.status = 404;
      throw error;
    }

    return requestRepository.create({
      customerId,
      shopId: shop_id,
      deviceType: device_type.trim(),
      deviceModel: device_model.trim(),
      problemDescription: problem_description.trim()
    });
  },

  async getCustomerRequests(customerId) {
    return requestRepository.findByCustomerId(customerId);
  },

  async getShopRequests(shopId, ownerUserId) {
    const shop = await shopRepository.findById(shopId);
    if (!shop) {
      const error = new Error('Repair shop not found.');
      error.status = 404;
      throw error;
    }

    if (shop.owner_user_id !== ownerUserId) {
      const error = new Error('Access denied. You can only view requests for your own shop.');
      error.status = 403;
      throw error;
    }

    return requestRepository.findByShopId(shopId);
  },

  async getRequestById(requestId, user) {
    const request = await requestRepository.findById(requestId);
    if (!request) {
      const error = new Error('Repair request not found.');
      error.status = 404;
      throw error;
    }

    const isCustomerOwner = request.customer_id === user.userId;
    const isShopOwner = request.shop_owner_id === user.userId;

    if (!isCustomerOwner && !isShopOwner) {
      const error = new Error('Access denied. You do not have permission to view this request.');
      error.status = 403;
      throw error;
    }

    return request;
  },

  async updateRequestStatus(requestId, ownerUserId, newStatus) {
    const allowedTransitions = [REQUEST_STATUS.ACCEPTED, REQUEST_STATUS.REJECTED];
    if (!allowedTransitions.includes(newStatus)) {
      const error = new Error(`Invalid status. Must be one of: ${allowedTransitions.join(', ')}`);
      error.status = 400;
      throw error;
    }

    const request = await requestRepository.findById(requestId);
    if (!request) {
      const error = new Error('Repair request not found.');
      error.status = 404;
      throw error;
    }

    if (request.shop_owner_id !== ownerUserId) {
      const error = new Error('Access denied. Only the shop owner can update this request.');
      error.status = 403;
      throw error;
    }

    if (request.request_status !== REQUEST_STATUS.PENDING) {
      const error = new Error(`Cannot update request. Current status is already '${request.request_status}'.`);
      error.status = 400;
      throw error;
    }

    const updatedRequest = await requestRepository.updateStatus(requestId, newStatus);

    await notificationRepository.create({
      userId: request.customer_id,
      requestId: request.request_id,
      message: `Your repair request (${request.reference_number}) has been ${newStatus.toLowerCase()} by ${request.shop_name}.`
    });

    return updatedRequest;
  }
};

module.exports = requestService;