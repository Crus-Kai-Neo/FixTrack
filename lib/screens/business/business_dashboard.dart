import 'package:flutter/material.dart';
import '../../models/repair_request.dart';
import '../../services/mock_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/shop_request_card.dart';
import '../shared/notifications_screen.dart';
import 'request_details_screen.dart';

/// Figure 14 - FixTrack Business-Sided Dashboard.
class BusinessDashboard extends StatelessWidget {
  final VoidCallback onGoToRequests;

  const BusinessDashboard({super.key, required this.onGoToRequests});

  Widget _stat(String label, int value, IconData icon) {
    return Expanded(
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('$value',
                    style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryDark)),
                Icon(icon, color: AppColors.primary),
              ],
            ),
            const SizedBox(height: 4),
            Text(label,
                style: const TextStyle(
                    fontSize: 13, color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListenableBuilder(
        listenable: MockService.instance,
        builder: (context, _) {
          final s = MockService.instance;
          final all = s.shopRequests;
          final pending =
              all.where((r) => r.stage == RequestStage.pending).toList();
          final active = all.where((r) => r.isInProgress).toList();
          final completed = all.where((r) => r.isCompleted).length;

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
                        const Text('FixTrack for Business',
                            style: TextStyle(
                                fontSize: 12, color: AppColors.textMuted)),
                        Text(s.userName,
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primaryDark)),
                      ],
                    ),
                  ),
                  NotificationBell(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              const NotificationsScreen(showBack: true)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text('Dashboard',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryDark)),
              const SizedBox(height: 14),
              Row(
                children: [
                  _stat('Total requests', all.length,
                      Icons.assignment_outlined),
                  const SizedBox(width: 12),
                  _stat('Pending review', pending.length,
                      Icons.hourglass_empty_rounded),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _stat('Active repairs', active.length, Icons.build_outlined),
                  const SizedBox(width: 12),
                  _stat('Completed', completed, Icons.check_circle_outline),
                ],
              ),
              if (pending.isNotEmpty) ...[
                const SizedBox(height: 14),
                GestureDetector(
                  onTap: onGoToRequests,
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  pending.length == 1
                                      ? '1 request to review'
                                      : '${pending.length} requests to review',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primaryDark)),
                              Text(
                                  '${pending.first.customerName} · ${pending.first.id}',
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textMuted)),
                            ],
                          ),
                        ),
                        const Text('Requests',
                            style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600)),
                        const Icon(Icons.chevron_right_rounded,
                            color: AppColors.primary),
                      ],
                    ),
                  ),
                ),
              ],
              const SectionHeader(title: 'Active Repairs'),
              if (active.isEmpty)
                const Text('No active repairs right now.',
                    style: TextStyle(color: AppColors.textMuted))
              else
                for (final r in active)
                  ShopRequestCard(
                    request: r,
                    showEstimate: true,
                    buttonText: 'View Details',
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => RequestDetailsScreen(request: r)),
                    ),
                  ),
            ],
          );
        },
      ),
    );
  }
}
