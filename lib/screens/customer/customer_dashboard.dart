import 'package:flutter/material.dart';
import '../../models/repair_request.dart';
import '../../services/mock_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/primary_button.dart';
import 'find_shops_screen.dart';
import 'repair_estimate_screen.dart';
import 'track_repair_screen.dart';

/// Figure 3 - FixTrack Customer Dashboard.
class CustomerDashboard extends StatelessWidget {
  final VoidCallback onGoToRepairs;
  final VoidCallback onGoToNotifications;

  const CustomerDashboard({
    super.key,
    required this.onGoToRepairs,
    required this.onGoToNotifications,
  });

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListenableBuilder(
        listenable: MockService.instance,
        builder: (context, _) {
          final s = MockService.instance;
          final mine = s.customerRequests;
          final waiting =
              mine.where((r) => r.stage == RequestStage.estimateSent).toList();
          final live = mine
              .where((r) =>
                  r.stage != RequestStage.rejected &&
                  r.stage != RequestStage.estimateRejected &&
                  !r.isCompleted)
              .toList();
          final recent = mine.where((r) => r.isCompleted).take(3).toList();
          final firstName = s.userName.split(' ').first;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Row(
                children: [
                  InitialsAvatar(name: s.userName),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_greeting(),
                            style: const TextStyle(
                                fontSize: 13, color: AppColors.textMuted)),
                        Text('Hello, $firstName',
                            style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primaryDark)),
                      ],
                    ),
                  ),
                  NotificationBell(onTap: onGoToNotifications),
                ],
              ),
              const SizedBox(height: 20),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Need a repair?',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryDark)),
                    const SizedBox(height: 4),
                    const Text('Find a repair shop and request a repair.',
                        style: TextStyle(color: AppColors.textMuted)),
                    const SizedBox(height: 16),
                    PrimaryButton(
                      text: 'Report a Repair',
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const FindShopsScreen()),
                      ),
                    ),
                  ],
                ),
              ),
              if (waiting.isNotEmpty) ...[
                const SizedBox(height: 14),
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            RepairEstimateScreen(request: waiting.first)),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.receipt_long_rounded,
                            color: AppColors.primary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            waiting.length == 1
                                ? '1 estimate is waiting for your review'
                                : '${waiting.length} estimates are waiting for your review',
                            style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryDark),
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded,
                            color: AppColors.primary),
                      ],
                    ),
                  ),
                ),
              ],
              SectionHeader(
                  title: 'Active Repair',
                  actionText: 'View all',
                  onAction: onGoToRepairs),
              if (live.isEmpty)
                const AppCard(
                  child: Text('No active repairs yet.',
                      style: TextStyle(color: AppColors.textMuted)),
                )
              else
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                              child: LabelValue(
                                  label: 'Device', value: live.first.deviceModel)),
                          Expanded(
                              child: LabelValue(
                                  label: 'Shop', value: live.first.shopName)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          RequestChip(request: live.first),
                          const SizedBox(width: 8),
                          Text('Updated ${timeAgo(live.first.updatedAt)}',
                              style: const TextStyle(
                                  fontSize: 12, color: AppColors.textMuted)),
                        ],
                      ),
                      const SizedBox(height: 14),
                      PrimaryButton(
                        text: 'View Details',
                        outlined: true,
                        onPressed: () => openRepair(context, live.first),
                      ),
                    ],
                  ),
                ),
              SectionHeader(
                  title: 'Recent Repairs',
                  actionText: 'See all',
                  onAction: onGoToRepairs),
              if (recent.isEmpty)
                const Text('Completed repairs will appear here.',
                    style: TextStyle(color: AppColors.textMuted))
              else
                for (final r in recent)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: AppCard(
                      padding: const EdgeInsets.all(12),
                      onTap: () => openRepair(context, r),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.primarySoft,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.check_rounded,
                                color: AppColors.primary),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(r.deviceModel,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w700)),
                                Text('Completed · ${r.shopName}',
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textMuted)),
                              ],
                            ),
                          ),
                          const StatusChip(
                              label: 'Done', color: AppColors.success),
                        ],
                      ),
                    ),
                  ),
            ],
          );
        },
      ),
    );
  }
}
