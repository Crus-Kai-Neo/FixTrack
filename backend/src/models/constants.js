const USER_ROLES = Object.freeze({
  CUSTOMER: 'Customer',
  BUSINESS: 'Business'
});

const REQUEST_STATUS = Object.freeze({
  PENDING: 'Pending',
  ACCEPTED: 'Accepted',
  REJECTED: 'Rejected'
});

const ESTIMATE_STATUS = Object.freeze({
  SENT: 'Sent',
  ACCEPTED: 'Accepted',
  REJECTED: 'Rejected'
});

const REPAIR_STATUS = Object.freeze({
  RECEIVED: 'Received',
  DIAGNOSING: 'Diagnosing',
  REPAIRING: 'Repairing',
  READY: 'Ready',
  COLLECTED: 'Collected'
});

const REPAIR_STATUS_FLOW = Object.freeze([
  REPAIR_STATUS.RECEIVED,
  REPAIR_STATUS.DIAGNOSING,
  REPAIR_STATUS.REPAIRING,
  REPAIR_STATUS.READY,
  REPAIR_STATUS.COLLECTED
]);

module.exports = {
  USER_ROLES,
  REQUEST_STATUS,
  ESTIMATE_STATUS,
  REPAIR_STATUS,
  REPAIR_STATUS_FLOW
};