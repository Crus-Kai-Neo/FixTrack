import 'package:flutter/material.dart';
import '../../models/repair_request.dart';
import '../../services/mock_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/primary_button.dart';
import 'repair_booked_screen.dart';

/// Figure 6 - FixTrack Repair Estimates (customer reviews an estimate).
class RepairEstimateScreen extends StatelessWidget {
  final RepairRequest request;

  const RepairEstimateScreen({super.key, required this.request});

  void _accept(BuildContext context) {
    MockService.instance.acceptEstimate(request);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (_) => RepairBookedScreen(request: request)),
    );
  }

  Future<void> _reject(BuildContext context) async {
    final ok = await confirmDialog(
      context,
      title: 'Reject estimate?',
      message: 'The repair will not be booked if you reject this estimate.',
      confirmText: 'Reject',
      danger: true,
    );
    if (!ok || !context.mounted) return;
    MockService.instance.rejectEstimate(request);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final r = request;
    return Scaffold(
      appBar: AppBar(title: const Text('Repair Estimate')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Estimated Cost',
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark)),
                  const SizedBox(height: 4),
                  Text(formatRs(r.estimatedCost),
                      style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary)),
                  const SizedBox(height: 14),
                  LabelValue(
                      label: 'Estimated Repair Time',
                      value: r.estimatedTime ?? '-'),
                  if (r.shopNotes != null) ...[
                    const SizedBox(height: 14),
                    LabelValue(label: 'Shop Notes', value: r.shopNotes!),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LabelValue(label: 'Repair ID', value: r.id),
                  const SizedBox(height: 12),
                  LabelValue(label: 'Device', value: r.deviceModel),
                  const SizedBox(height: 12),
                  LabelValue(label: 'Problem', value: r.problem),
                  const SizedBox(height: 12),
                  LabelValue(label: 'Repair Shop', value: r.shopName),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text('Estimate provided by ${r.shopName}',
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textMuted)),
            ),
            const SizedBox(height: 12),
            PrimaryButton(
                text: 'Accept Estimate', onPressed: () => _accept(context)),
            const SizedBox(height: 10),
            PrimaryButton(
              text: 'Reject Estimate',
              outlined: true,
              color: AppColors.error,
              onPressed: () => _reject(context),
            ),
          ],
        ),
      ),
    );
  }
}
