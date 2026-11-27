import 'package:flutter/material.dart';
import '../../services/mock_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common_widgets.dart';

/// PROPOSED screen (not one of the 13 documented figures).
/// Shows request and repair notifications for customers and shops.
class NotificationsScreen extends StatelessWidget {
  final bool showBack;

  const NotificationsScreen({super.key, this.showBack = false});

  @override
  Widget build(BuildContext context) {
    final service = MockService.instance;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        automaticallyImplyLeading: showBack,
        actions: [
          TextButton(
            onPressed: service.markAllRead,
            child: const Text('Mark all read',
                style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: service,
        builder: (context, _) {
          final list = service.myNotifications;
          if (list.isEmpty) {
            return const EmptyState(
                icon: Icons.notifications_none_rounded,
                message: 'No notifications yet.');
          }
          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: list.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final n = list[i];
              return AppCard(
                onTap: () => service.markRead(n),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 6),
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: n.isRead ? Colors.transparent : AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(n.title,
                              style: TextStyle(
                                  fontWeight: n.isRead
                                      ? FontWeight.w600
                                      : FontWeight.w800,
                                  color: AppColors.textDark)),
                          const SizedBox(height: 4),
                          Text(n.message,
                              style: const TextStyle(
                                  color: AppColors.textMuted, fontSize: 13)),
                          const SizedBox(height: 6),
                          Text(timeAgo(n.time),
                              style: const TextStyle(
                                  color: AppColors.textMuted, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
