import 'package:flutter/material.dart';
import '../../models/repair_request.dart';
import '../../services/mock_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/primary_button.dart';
import 'repair_estimate_screen.dart';

/// Opens the right screen for a request:
/// the estimate screen if an estimate is waiting, otherwise the tracker.
void openRepair(BuildContext context, RepairRequest r) {
  if (r.stage == RequestStage.estimateSent) {
    Navigator.push(context,
        MaterialPageRoute(builder: (_) => RepairEstimateScreen(request: r)));
  } else {
    Navigator.push(context,
        MaterialPageRoute(builder: (_) => TrackRepairScreen(request: r)));
  }
}

/// Figure 8 - FixTrack Track Repairs (customer follows repair progress).
class TrackRepairScreen extends StatelessWidget {
  final RepairRequest request;

  const TrackRepairScreen({super.key, required this.request});

  int _currentIndex(RepairRequest r) {
    final s = r.status;
    if (s == null) return -1;
    if (s == RepairStatus.collected) return RepairStatus.values.length;
    return s.index;
  }

  String _stageMessage(RepairRequest r) {
    switch (r.stage) {
      case RequestStage.pending:
        return '${r.shopName} has not reviewed your request yet.';
      case RequestStage.accepted:
        return 'Your request was accepted. The shop is preparing an estimate.';
      case RequestStage.estimateSent:
        return 'An estimate is ready for you to review.';
      case RequestStage.estimateRejected:
        return 'You rejected this estimate, so no booking was made.';
      case RequestStage.rejected:
        return 'The shop could not accept this request.';
      case RequestStage.booked:
        return 'Booking confirmed.';
    }
  }

  void _contactShop(BuildContext context, RepairRequest r) {
    final shop = MockService.instance.shopById(r.shopId);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(shop.name),
        content: Text('Phone: ${shop.phone}\nLocation: ${shop.location}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Track Repair')),
      body: ListenableBuilder(
        listenable: MockService.instance,
        builder: (context, _) {
          final r = request;
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('Repair #${r.id}',
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.textMuted)),
                        const Spacer(),
                        RequestChip(request: r),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                            child: LabelValue(
                                label: 'Device', value: r.deviceModel)),
                        Expanded(
                            child: LabelValue(
                                label: 'Repair Shop', value: r.shopName)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              if (!r.isBooked)
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Request Progress',
                          style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryDark)),
                      const SizedBox(height: 8),
                      Text(_stageMessage(r),
                          style: const TextStyle(color: AppColors.textMuted)),
                      if (r.stage == RequestStage.estimateSent) ...[
                        const SizedBox(height: 14),
                        PrimaryButton(
                          text: 'Review Estimate',
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    RepairEstimateScreen(request: r)),
                          ),
                        ),
                      ],
                    ],
                  ),
                )
              else ...[
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Repair Progress',
                          style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryDark)),
                      if (r.status == null) ...[
                        const SizedBox(height: 8),
                        Text(
                            'Booking confirmed. Please hand your device over to ${r.shopName}.',
                            style:
                                const TextStyle(color: AppColors.textMuted)),
                      ],
                      const SizedBox(height: 16),
                      ProgressStepper(
                        steps:
                            RepairStatus.values.map((s) => s.label).toList(),
                        currentIndex: _currentIndex(r),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Repair Details',
                          style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryDark)),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                              child: LabelValue(
                                  label: 'Estimated Cost',
                                  value: formatRs(r.estimatedCost))),
                          Expanded(
                              child: LabelValue(
                                  label: 'Estimated Completion',
                                  value: r.estimatedTime ?? '-')),
                        ],
                      ),
                      const SizedBox(height: 14),
                      LabelValue(label: 'Problem', value: r.problem),
                      const SizedBox(height: 16),
                      PrimaryButton(
                          text: 'Contact Shop',
                          onPressed: () => _contactShop(context, r)),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Center(
                child: Text('Last updated: ${timeAgo(r.updatedAt)}',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textMuted)),
              ),
            ],
          );
        },
      ),
    );
  }
}
