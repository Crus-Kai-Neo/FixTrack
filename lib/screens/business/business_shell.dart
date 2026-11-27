import 'package:flutter/material.dart';
import '../../models/repair_request.dart';
import '../../services/mock_service.dart';
import '../../theme/app_colors.dart';
import '../shared/profile_screen.dart';
import 'business_dashboard.dart';
import 'customer_requests_screen.dart';
import 'repair_lists_screen.dart';

/// Holds the repair shop's bottom navigation bar and the 4 tabs.
class BusinessShell extends StatefulWidget {
  const BusinessShell({super.key});

  @override
  State<BusinessShell> createState() => _BusinessShellState();
}

class _BusinessShellState extends State<BusinessShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          BusinessDashboard(onGoToRequests: () => setState(() => _index = 1)),
          const CustomerRequestsScreen(),
          const RepairListsScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: ListenableBuilder(
        listenable: MockService.instance,
        builder: (context, _) {
          final pending = MockService.instance.shopRequests
              .where((r) => r.stage == RequestStage.pending)
              .length;
          return NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: (i) => setState(() => _index = i),
            backgroundColor: Colors.white,
            indicatorColor: AppColors.primarySoft,
            destinations: [
              const NavigationDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard_rounded),
                label: 'Dashboard',
              ),
              NavigationDestination(
                icon: Badge(
                  isLabelVisible: pending > 0,
                  label: Text('$pending'),
                  child: const Icon(Icons.assignment_outlined),
                ),
                selectedIcon: Badge(
                  isLabelVisible: pending > 0,
                  label: Text('$pending'),
                  child: const Icon(Icons.assignment_rounded),
                ),
                label: 'Requests',
              ),
              const NavigationDestination(
                icon: Icon(Icons.build_outlined),
                selectedIcon: Icon(Icons.build_rounded),
                label: 'Repairs',
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
