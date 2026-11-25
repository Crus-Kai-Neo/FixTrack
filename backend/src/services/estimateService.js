const {
  estimateRepository,
  requestRepository,
  bookingRepository,
  notificationRepository
} = require('../repositories');
const { REQUEST_STATUS, ESTIMATE_STATUS } = require('../models/constants');

const estimateService = {
  async createEstimate(ownerUserId, { request_id, estimated_cost, estimated_completion_time, business_notes }) {
    const request = await requestRepository.findById(request_id);
    if (!request) {
      const error = new Error('Repair request not found.');
      error.status = 404;
      throw error;
    }

    if (request.shop_owner_id !== ownerUserId) {
      const error = new Error('Access denied. Only the shop owner can send an estimate for this request.');
      error.status = 403;
      throw error;
    }

    if (request.request_status !== REQUEST_STATUS.ACCEPTED) {
      const error = new Error('Estimates can only be sent for accepted repair requests.');
      error.status = 400;
      throw error;
    }

    const existingEstimate = await estimateRepository.findByRequestId(request_id);
    if (existingEstimate) {
      const error = new Error('An estimate has already been sent for this repair request.');
      error.status = 409;
      throw error;
    }

    const estimate = await estimateRepository.create({
      requestId: request_id,
      estimatedCost: estimated_cost,
      estimatedCompletionTime: estimated_completion_time.trim(),
      businessNotes: business_notes ? business_notes.trim() : null
    });

    // Notify the customer that an estimate is ready
    await notificationRepository.create({
      userId: request.customer_id,
      requestId: request.request_id,
      message: `${request.shop_name} sent an estimate of Rs. ${estimated_cost} for request ${request.reference_number}.`
    });

    return estimate;
  },

  async getEstimateByRequestId(requestId, user) {
    const request = await requestRepository.findById(requestId);
    if (!request) {
      const error = new Error('Repair request not found.');
      error.status = 404;
      throw error;
    }

    const isCustomerOwner = request.customer_id === user.userId;
    const isShopOwner = request.shop_owner_id === user.userId;

    if (!isCustomerOwner && !isShopOwner) {
      const error = new Error('Access denied. You do not have permission to view this estimate.');
      error.status = 403;
      throw error;
    }

    const estimate = await estimateRepository.findByRequestId(requestId);
    if (!estimate) {
      const error = new Error('No estimate found for this repair request.');
      error.status = 404;
      throw error;
    }

    return estimate;
  },

  async respondToEstimate(estimateId, customerId, decision) {
    const allowedDecisions = [ESTIMATE_STATUS.ACCEPTED, ESTIMATE_STATUS.REJECTED];
    if (!allowedDecisions.includes(decision)) {
      const error = new Error(`Invalid decision. Must be one of: ${allowedDecisions.join(', ')}`);
      error.status = 400;
      throw error;
    }

    const estimate = await estimateRepository.findById(estimateId);
    if (!estimate) {
      const error = new Error('Estimate not found.');
      error.status = 404;
      throw error;
    }

    if (estimate.customer_id !== customerId) {
      const error = new Error('Access denied. Only the customer who made the request can respond to this estimate.');
      error.status = 403;
      throw error;
    }

    if (estimate.estimate_status !== ESTIMATE_STATUS.SENT) {
      const error = new Error(`Estimate has already been ${estimate.estimate_status.toLowerCase()}.`);
      error.status = 400;
      throw error;
    }

    const updatedEstimate = await estimateRepository.updateStatus(estimateId, decision);
    let booking = null;

    if (decision === ESTIMATE_STATUS.ACCEPTED) {
      booking = await bookingRepository.createWithInitialHistory({
        requestId: estimate.request_id,
        estimateId: estimate.estimate_id,
        remarks: 'Customer accepted estimate. Booking confirmed.'
      });

      await notificationRepository.create({
        userId: estimate.shop_owner_id,
        requestId: estimate.request_id,
        message: `Customer accepted your estimate for ${estimate.reference_number}. Booking #${booking.booking_id} is now confirmed.`
      });
    } else {
      await notificationRepository.create({
        userId: estimate.shop_owner_id,
        requestId: estimate.request_id,
        message: `Customer rejected your estimate for ${estimate.reference_number}.`
      });
    }

    return {
      estimate: updatedEstimate,
      booking
    };
  }
};

module.exports = estimateService;