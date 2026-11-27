import 'package:flutter/material.dart';
import '../../models/repair_request.dart';
import '../../services/mock_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/primary_button.dart';
import 'send_estimate_screen.dart';
import 'update_status_screen.dart';

/// Figure 11 - FixTrack Customer Request Details.
class RequestDetailsScreen extends StatelessWidget {
  final RepairRequest request;

  const RequestDetailsScreen({super.key, required this.request});

  void _accept(BuildContext context) {
    MockService.instance.acceptRequest(request);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (_) => SendEstimateScreen(request: request)),
    );
  }

  Future<void> _reject(BuildContext context) async {
    final ok = await confirmDialog(
      context,
      title: 'Reject request?',
      message: 'The customer will be told that you cannot take this repair.',
      confirmText: 'Reject',
      danger: true,
    );
    if (!ok || !context.mounted) return;
    MockService.instance.rejectRequest(request);
    Navigator.pop(context);
  }

  Widget _note(String text) {
    return Center(
      child: Text(text,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.textMuted)),
    );
  }

  Widget _actions(BuildContext context, RepairRequest r) {
    switch (r.stage) {
      case RequestStage.pending:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Accept this request to prepare a repair estimate.',
                style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
            const SizedBox(height: 10),
            PrimaryButton(text: 'Accept', onPressed: () => _accept(context)),
            const SizedBox(height: 10),
            PrimaryButton(
              text: 'Reject',
              outlined: true,
              color: AppColors.error,
              onPressed: () => _reject(context),
            ),
          ],
        );
      case RequestStage.accepted:
        return PrimaryButton(
          text: 'Send Estimate',
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => SendEstimateScreen(request: r)),
          ),
        );
      case RequestStage.estimateSent:
        return _note('Waiting for the customer to accept or reject your estimate.');
      case RequestStage.estimateRejected:
        return _note('The customer rejected the estimate.');
      case RequestStage.rejected:
        return _note('You rejected this request.');
      case RequestStage.booked:
        if (r.isCompleted) {
          return _note('This repair is complete. The device was collected.');
        }
        return PrimaryButton(
          text: 'Update Status',
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => UpdateStatusScreen(request: r)),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Request Details')),
      body: ListenableBuilder(
        listenable: MockService.instance,
        builder: (context, _) {
          final r = request;
          final hasEstimate = r.stage == RequestStage.estimateSent || r.isBooked;
          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  children: [
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text('Repair #${r.id}',
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textMuted)),
                              const Spacer(),
                              RequestChip(request: r),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              InitialsAvatar(name: r.customerName, radius: 20),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Customer',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textMuted)),
                                  Text(r.customerName,
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700)),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text('Submitted ${timeAgo(r.submittedAt)}',
                              style: const TextStyle(
                                  fontSize: 12, color: AppColors.textMuted)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Repair Information',
                              style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primaryDark)),
                          const SizedBox(height: 14),
                          LabelValue(label: 'Device', value: r.deviceModel),
                          const SizedBox(height: 12),
                          LabelValue(label: 'Device Type', value: r.deviceType),
                          const SizedBox(height: 12),
                          LabelValue(label: 'Problem', value: r.problem),
                        ],
                      ),
                    ),
                    if (hasEstimate) ...[
                      const SizedBox(height: 12),
                      AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Estimate',
                                style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primaryDark)),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Expanded(
                                    child: LabelValue(
                                        label: 'Cost',
                                        value: formatRs(r.estimatedCost))),
                                Expanded(
                                    child: LabelValue(
                                        label: 'Time',
                                        value: r.estimatedTime ?? '-')),
                              ],
                            ),
                            if (r.shopNotes != null) ...[
                              const SizedBox(height: 12),
                              LabelValue(label: 'Notes', value: r.shopNotes!),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  child: _actions(context, r),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
