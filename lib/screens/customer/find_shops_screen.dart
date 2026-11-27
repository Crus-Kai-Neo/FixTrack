import 'package:flutter/material.dart';
import '../../services/mock_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/primary_button.dart';
import 'report_repair_screen.dart';

/// Figure 4 - FixTrack Find Repair Shops.
class FindShopsScreen extends StatefulWidget {
  const FindShopsScreen({super.key});

  @override
  State<FindShopsScreen> createState() => _FindShopsScreenState();
}

class _FindShopsScreenState extends State<FindShopsScreen> {
  final _filters = const ['All', 'Phones', 'Laptops', 'Tablets'];
  String _query = '';
  int _filter = 0;

  @override
  Widget build(BuildContext context) {
    final q = _query.trim().toLowerCase();
    final shops = MockService.instance.shops.where((shop) {
      final matchesText = q.isEmpty ||
          shop.name.toLowerCase().contains(q) ||
          shop.location.toLowerCase().contains(q);
      final matchesFilter =
          _filter == 0 || shop.deviceTypes.contains(_filters[_filter]);
      return matchesText && matchesFilter;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Find a Repair Shop')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: TextField(
              onChanged: (v) => setState(() => _query = v),
              decoration: const InputDecoration(
                hintText: 'Search repair shops...',
                prefixIcon:
                    Icon(Icons.search_rounded, color: AppColors.textMuted),
              ),
            ),
          ),
          ChipRow(
            labels: _filters,
            selected: _filter,
            onSelected: (i) => setState(() => _filter = i),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: shops.isEmpty
                ? const EmptyState(
                    icon: Icons.search_off_rounded,
                    message: 'No repair shops match your search.')
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    itemCount: shops.length,
                    itemBuilder: (context, i) {
                      final shop = shops[i];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: AppCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(shop.name,
                                        style: const TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.primaryDark)),
                                  ),
                                  StatusChip(
                                    label: shop.isOpen ? 'Open' : 'Closed',
                                    color: shop.isOpen
                                        ? AppColors.success
                                        : AppColors.textMuted,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(Icons.location_on_outlined,
                                      size: 16, color: AppColors.textMuted),
                                  const SizedBox(width: 4),
                                  Text(shop.location,
                                      style: const TextStyle(
                                          color: AppColors.textMuted)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(shop.deviceTypes.join(' • '),
                                  style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textMuted)),
                              const SizedBox(height: 14),
                              PrimaryButton(
                                text: 'Request Repair',
                                outlined: true,
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        ReportRepairScreen(shop: shop),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
