const crypto = require('crypto');
const {
  requestRepository,
  shopRepository,
  notificationRepository
} = require('../repositories');
const { REQUEST_STATUS } = require('../models/constants');

function generateReferenceNumber() {
  const datePart = new Date().toISOString().slice(0, 10).replace(/-/g, '');
  const randomPart = crypto.randomBytes(3).toString('hex').toUpperCase();
  return `FT-${datePart}-${randomPart}`;
}

const requestService = {
  async createRequest(customerId, { shop_id, device_type, device_model, problem_description }) {
    const shop = await shopRepository.findById(shop_id);
    if (!shop) {
      const error = new Error('Selected repair shop not found.');
      error.status = 404;
      throw error;
    }

    const referenceNumber = generateReferenceNumber();

    const createdRequest = await requestRepository.create({
      referenceNumber,
      customerId,
      shopId: shop_id,
      deviceType: device_type.trim(),
      deviceModel: device_model.trim(),
      problemDescription: problem_description.trim()
    });

    // Notify the shop owner about the new repair request
    await notificationRepository.create({
      userId: shop.owner_user_id,
      requestId: createdRequest.request_id,
      message: `New repair request (${referenceNumber}) received for ${createdRequest.device_type} - ${createdRequest.device_model}.`
    });

    return createdRequest;
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

    // Notify the customer about the status decision
    await notificationRepository.create({
      userId: request.customer_id,
      requestId: request.request_id,
      message: `Your repair request (${request.reference_number}) has been ${newStatus.toLowerCase()} by ${request.shop_name}.`
    });

    return updatedRequest;
  }
};

module.exports = requestService;