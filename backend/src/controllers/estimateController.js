const estimateService = require('../services/estimateService');

const estimateController = {
  async createEstimate(req, res, next) {
    try {
      const { request_id, estimated_cost, estimated_completion_time, business_notes } = req.body;

      if (!request_id || estimated_cost === undefined || !estimated_completion_time) {
        return res.status(400).json({
          success: false,
          message: 'request_id, estimated_cost, and estimated_completion_time are required.'
        });
      }

      const parsedRequestId = parseInt(request_id, 10);
      const parsedCost = parseFloat(estimated_cost);

      if (Number.isNaN(parsedRequestId)) {
        return res.status(400).json({
          success: false,
          message: 'Invalid request_id.'
        });
      }

      if (Number.isNaN(parsedCost) || parsedCost <= 0) {
        return res.status(400).json({
          success: false,
          message: 'estimated_cost must be a positive number.'
        });
      }

      const estimate = await estimateService.createEstimate(req.user.userId, {
        request_id: parsedRequestId,
        estimated_cost: parsedCost,
        estimated_completion_time,
        business_notes
      });

      res.status(201).json({
        success: true,
        message: 'Estimate sent successfully',
        data: estimate
      });
    } catch (error) {
      next(error);
    }
  },

  async getEstimateByRequestId(req, res, next) {
    try {
      const requestId = parseInt(req.params.requestId, 10);
      if (Number.isNaN(requestId)) {
        return res.status(400).json({
          success: false,
          message: 'Invalid request ID.'
        });
      }

      const estimate = await estimateService.getEstimateByRequestId(requestId, req.user);

      res.status(200).json({
        success: true,
        message: 'Estimate retrieved successfully',
        data: estimate
      });
    } catch (error) {
      next(error);
    }
  },

  async respondToEstimate(req, res, next) {
    try {
      const estimateId = parseInt(req.params.id, 10);
      const { estimate_status } = req.body;

      if (Number.isNaN(estimateId)) {
        return res.status(400).json({
          success: false,
          message: 'Invalid estimate ID.'
        });
      }

      if (!estimate_status) {
        return res.status(400).json({
          success: false,
          message: 'estimate_status is required (Accepted or Rejected).'
        });
      }

      const result = await estimateService.respondToEstimate(
        estimateId,
        req.user.userId,
        estimate_status
      );

      res.status(200).json({
        success: true,
        message: `Estimate ${estimate_status.toLowerCase()} successfully`,
        data: result
      });
    } catch (error) {
      next(error);
    }
  }
};

module.exports = estimateController;