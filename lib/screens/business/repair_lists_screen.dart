import 'package:flutter/material.dart';
import '../../models/repair_request.dart';
import '../../services/mock_service.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/shop_request_card.dart';
import 'request_details_screen.dart';
import 'update_status_screen.dart';

/// Figure 9 - FixTrack Repair Lists (confirmed bookings on the business side).
class RepairListsScreen extends StatefulWidget {
  const RepairListsScreen({super.key});

  @override
  State<RepairListsScreen> createState() => _RepairListsScreenState();
}

class _RepairListsScreenState extends State<RepairListsScreen> {
  final _filters = const ['All', 'In Progress', 'Completed'];
  int _filter = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Repairs'),
        automaticallyImplyLeading: false,
      ),
      body: ListenableBuilder(
        listenable: MockService.instance,
        builder: (context, _) {
          final booked =
              MockService.instance.shopRequests.where((r) => r.isBooked).toList();
          final List<RepairRequest> list;
          if (_filter == 1) {
            list = booked.where((r) => r.isInProgress).toList();
          } else if (_filter == 2) {
            list = booked.where((r) => r.isCompleted).toList();
          } else {
            list = booked;
          }

          return Column(
            children: [
              const SizedBox(height: 4),
              ChipRow(
                labels: _filters,
                selected: _filter,
                onSelected: (i) => setState(() => _filter = i),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: list.isEmpty
                    ? const EmptyState(
                        icon: Icons.build_circle_outlined,
                        message: 'No confirmed repairs yet.')
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        itemCount: list.length,
                        itemBuilder: (context, i) {
                          final r = list[i];
                          return ShopRequestCard(
                            request: r,
                            showEstimate: true,
                            buttonText:
                                r.isCompleted ? 'View Details' : 'Update Status',
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => r.isCompleted
                                    ? RequestDetailsScreen(request: r)
                                    : UpdateStatusScreen(request: r),
                              ),
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
