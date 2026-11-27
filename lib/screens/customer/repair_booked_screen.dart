import 'package:flutter/material.dart';
import '../../models/repair_request.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/primary_button.dart';
import 'track_repair_screen.dart';

/// Figure 7 - FixTrack Repair Booked (confirmed booking).
class RepairBookedScreen extends StatelessWidget {
  final RepairRequest request;

  const RepairBookedScreen({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    final r = request;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 24),
            Center(
              child: Container(
                width: 88,
                height: 88,
                decoration: const BoxDecoration(
                    shape: BoxShape.circle, color: AppColors.primarySoft),
                child: const Icon(Icons.check_rounded,
                    size: 48, color: AppColors.primary),
              ),
            ),
            const SizedBox(height: 20),
            const Center(
              child: Text('Repair Booked!',
                  style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryDark)),
            ),
            const SizedBox(height: 6),
            const Center(
              child: Text('Your repair booking has been confirmed.',
                  style: TextStyle(color: AppColors.textMuted)),
            ),
            const SizedBox(height: 24),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Booking Summary',
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryDark)),
                  const SizedBox(height: 16),
                  Row(children: [
                    Expanded(child: LabelValue(label: 'Repair ID', value: r.id)),
                    Expanded(
                        child: LabelValue(
                            label: 'Device', value: r.deviceModel)),
                  ]),
                  const SizedBox(height: 14),
                  Row(children: [
                    Expanded(
                        child: LabelValue(
                            label: 'Repair Shop', value: r.shopName)),
                    Expanded(
                        child: LabelValue(
                            label: 'Estimated Cost',
                            value: formatRs(r.estimatedCost))),
                  ]),
                  const SizedBox(height: 14),
                  Row(children: [
                    Expanded(
                        child: LabelValue(
                            label: 'Estimated Time',
                            value: r.estimatedTime ?? '-')),
                    const Expanded(
                        child: LabelValue(
                            label: 'Status', value: 'Booking Confirmed')),
                  ]),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Next step: hand your device over to ${r.shopName}. The shop will update the repair status once it receives the device.',
                style: const TextStyle(color: AppColors.primaryDark),
              ),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              text: 'Track Repair',
              onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (_) => TrackRepairScreen(request: r)),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: () =>
                    Navigator.popUntil(context, (route) => route.isFirst),
                child: const Text('Back to Home',
                    style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
