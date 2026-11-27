import 'package:flutter/material.dart';
import '../../models/repair_request.dart';
import '../../services/mock_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/shop_request_card.dart';
import 'request_details_screen.dart';

/// Figure 10 - FixTrack Customer Requests.
class CustomerRequestsScreen extends StatefulWidget {
  const CustomerRequestsScreen({super.key});

  @override
  State<CustomerRequestsScreen> createState() =>
      _CustomerRequestsScreenState();
}

class _CustomerRequestsScreenState extends State<CustomerRequestsScreen> {
  int _filter = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Requests'),
        automaticallyImplyLeading: false,
      ),
      body: ListenableBuilder(
        listenable: MockService.instance,
        builder: (context, _) {
          final s = MockService.instance;
          final all = s.shopRequests;
          final pending =
              all.where((r) => r.stage == RequestStage.pending).toList();
          final completed = all.where((r) => r.isCompleted).toList();
          final list = _filter == 0
              ? all
              : (_filter == 1 ? pending : completed);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: Text('${s.userName} · ${all.length} total requests',
                    style: const TextStyle(color: AppColors.textMuted)),
              ),
              ChipRow(
                labels: [
                  'All (${all.length})',
                  'Pending (${pending.length})',
                  'Completed (${completed.length})',
                ],
                selected: _filter,
                onSelected: (i) => setState(() => _filter = i),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: list.isEmpty
                    ? const EmptyState(
                        icon: Icons.inbox_outlined,
                        message: 'No requests here yet.')
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        itemCount: list.length,
                        itemBuilder: (context, i) {
                          final r = list[i];
                          return ShopRequestCard(
                            request: r,
                            buttonText: r.stage == RequestStage.pending
                                ? 'Review Request'
                                : 'View Details',
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      RequestDetailsScreen(request: r)),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
