import 'package:flutter/material.dart';
import '../../models/repair_request.dart';
import '../../services/mock_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/primary_button.dart';
import 'track_repair_screen.dart';

/// Customer repair list and history (opens Figure 8 - Track Repairs).
class MyRepairsScreen extends StatefulWidget {
  const MyRepairsScreen({super.key});

  @override
  State<MyRepairsScreen> createState() => _MyRepairsScreenState();
}

class _MyRepairsScreenState extends State<MyRepairsScreen> {
  final _filters = const ['All', 'Pending', 'In Progress', 'Completed'];
  int _filter = 0;

  bool _matches(RepairRequest r) {
    switch (_filter) {
      case 1:
        return r.stage == RequestStage.pending ||
            r.stage == RequestStage.accepted ||
            r.stage == RequestStage.estimateSent;
      case 2:
        return r.isInProgress;
      case 3:
        return r.isCompleted;
      default:
        return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Repairs'),
        automaticallyImplyLeading: false,
      ),
      body: ListenableBuilder(
        listenable: MockService.instance,
        builder: (context, _) {
          final list =
              MockService.instance.customerRequests.where(_matches).toList();
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
                        message: 'No repairs here yet.')
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        itemCount: list.length,
                        itemBuilder: (context, i) {
                          final r = list[i];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: AppCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                          child: LabelValue(
                                              label: 'Device',
                                              value: r.deviceModel)),
                                      Expanded(
                                          child: LabelValue(
                                              label: 'Repair Shop',
                                              value: r.shopName)),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Text('Repair #${r.id}',
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: AppColors.textMuted)),
                                      const SizedBox(width: 8),
                                      RequestChip(request: r),
                                    ],
                                  ),
                                  if (r.estimatedCost != null) ...[
                                    const SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                            r.isCompleted
                                                ? 'Total Cost'
                                                : 'Estimated Cost',
                                            style: const TextStyle(
                                                color: AppColors.textMuted)),
                                        Text(formatRs(r.estimatedCost),
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w700)),
                                      ],
                                    ),
                                  ],
                                  const SizedBox(height: 14),
                                  PrimaryButton(
                                    text: r.stage == RequestStage.estimateSent
                                        ? 'Review Estimate'
                                        : 'View Details',
                                    outlined: true,
                                    onPressed: () => openRepair(context, r),
                                  ),
                                ],
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
