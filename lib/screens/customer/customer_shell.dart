import 'package:flutter/material.dart';
import '../../services/mock_service.dart';
import '../../theme/app_colors.dart';
import '../shared/notifications_screen.dart';
import '../shared/profile_screen.dart';
import 'customer_dashboard.dart';
import 'my_repairs_screen.dart';

/// Holds the customer's bottom navigation bar and the 4 tabs.
class CustomerShell extends StatefulWidget {
  const CustomerShell({super.key});

  @override
  State<CustomerShell> createState() => _CustomerShellState();
}

class _CustomerShellState extends State<CustomerShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          CustomerDashboard(
            onGoToRepairs: () => setState(() => _index = 1),
            onGoToNotifications: () => setState(() => _index = 2),
          ),
          const MyRepairsScreen(),
          const NotificationsScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: ListenableBuilder(
        listenable: MockService.instance,
        builder: (context, _) {
          final unread = MockService.instance.unreadCount;
          return NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: (i) => setState(() => _index = i),
            backgroundColor: Colors.white,
            indicatorColor: AppColors.primarySoft,
            destinations: [
              const NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_rounded),
                label: 'Home',
              ),
              const NavigationDestination(
                icon: Icon(Icons.build_outlined),
                selectedIcon: Icon(Icons.build_rounded),
                label: 'My Repairs',
              ),
              NavigationDestination(
                icon: Badge(
                  isLabelVisible: unread > 0,
                  label: Text('$unread'),
                  child: const Icon(Icons.notifications_none_rounded),
                ),
                selectedIcon: Badge(
                  isLabelVisible: unread > 0,
                  label: Text('$unread'),
                  child: const Icon(Icons.notifications_rounded),
                ),
                label: 'Notifications',
              ),
              const NavigationDestination(
                icon: Icon(Icons.person_outline_rounded),
                selectedIcon: Icon(Icons.person_rounded),
                label: 'Profile',
              ),
            ],
          );
        },
      ),
    );
  }
}
