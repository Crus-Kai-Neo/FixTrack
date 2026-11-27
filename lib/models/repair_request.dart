/// Workflow stages BEFORE and AT booking.
/// These are NOT the repair-progress statuses.
enum RequestStage {
  pending, // customer submitted, shop has not reviewed
  accepted, // shop accepted, estimate being prepared
  estimateSent, // shop sent estimate, customer must decide
  estimateRejected, // customer rejected the estimate
  rejected, // shop rejected the request
  booked, // customer accepted the estimate = confirmed booking
}

/// The 5 official repair-progress statuses (used after booking).
enum RepairStatus { received, diagnosing, repairing, ready, collected }

extension RepairStatusInfo on RepairStatus {
  String get label {
    switch (this) {
      case RepairStatus.received:
        return 'Received';
      case RepairStatus.diagnosing:
        return 'Diagnosing';
      case RepairStatus.repairing:
        return 'Repairing';
      case RepairStatus.ready:
        return 'Ready';
      case RepairStatus.collected:
        return 'Collected';
    }
  }

  String get description {
    switch (this) {
      case RepairStatus.received:
        return 'The shop has received the device.';
      case RepairStatus.diagnosing:
        return 'The technician is examining the device.';
      case RepairStatus.repairing:
        return 'The repair work is underway.';
      case RepairStatus.ready:
        return 'The device is ready for collection.';
      case RepairStatus.collected:
        return 'The customer has collected the device.';
    }
  }
}

extension RequestStageInfo on RequestStage {
  String get label {
    switch (this) {
      case RequestStage.pending:
        return 'Pending review';
      case RequestStage.accepted:
        return 'Accepted';
      case RequestStage.estimateSent:
        return 'Estimate sent';
      case RequestStage.estimateRejected:
        return 'Estimate rejected';
      case RequestStage.rejected:
        return 'Rejected';
      case RequestStage.booked:
        return 'Booked';
    }
  }
}

/// One repair request. The id is the unique reference number (e.g. FT-001).
class RepairRequest {
  final String id;
  final String customerName;
  final String deviceType;
  final String deviceModel;
  final String problem;
  final String shopId;
  final String shopName;
  final DateTime submittedAt;
  DateTime updatedAt;

  RequestStage stage;
  int? estimatedCost;
  String? estimatedTime;
  String? shopNotes;
  RepairStatus? status; // null until the shop receives the device

  RepairRequest({
    required this.id,
    required this.customerName,
    required this.deviceType,
    required this.deviceModel,
    required this.problem,
    required this.shopId,
    required this.shopName,
    required this.submittedAt,
    required this.updatedAt,
    this.stage = RequestStage.pending,
    this.estimatedCost,
    this.estimatedTime,
    this.shopNotes,
    this.status,
  });

  bool get isBooked => stage == RequestStage.booked;
  bool get isCompleted => isBooked && status == RepairStatus.collected;
  bool get isInProgress => isBooked && status != RepairStatus.collected;
}
