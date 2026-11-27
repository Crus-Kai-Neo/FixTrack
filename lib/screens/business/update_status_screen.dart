import 'package:flutter/material.dart';
import '../../models/repair_request.dart';
import '../../services/mock_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/primary_button.dart';

/// Figure 13 - FixTrack Update Customer Status.
/// Uses the 5 official repair statuses.
class UpdateStatusScreen extends StatefulWidget {
  final RepairRequest request;

  const UpdateStatusScreen({super.key, required this.request});

  @override
  State<UpdateStatusScreen> createState() => _UpdateStatusScreenState();
}

class _UpdateStatusScreenState extends State<UpdateStatusScreen> {
  RepairStatus? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.request.status;
  }

  bool get _canSave =>
      _selected != null && _selected != widget.request.status;

  void _save() {
    MockService.instance.updateStatus(widget.request, _selected!);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text('Status updated to ${_selected!.label}. Customer notified.')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.request;
    return Scaffold(
      appBar: AppBar(title: const Text('Update Status')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('Repair #${r.id}',
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.textMuted)),
                      const Spacer(),
                      RequestChip(request: r),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(r.deviceModel,
                      style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryDark)),
                  const SizedBox(height: 2),
                  Text('${r.customerName} · ${r.problem}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 13, color: AppColors.textMuted)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text('Repair Progress',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryDark)),
            const SizedBox(height: 4),
            const Text('Select the current repair status.',
                style: TextStyle(color: AppColors.textMuted)),
            const SizedBox(height: 12),
            for (final status in RepairStatus.values)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: GestureDetector(
                  onTap: () => setState(() => _selected = status),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: _selected == status
                          ? AppColors.primarySoft
                          : AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _selected == status
                            ? AppColors.primary
                            : AppColors.border,
                        width: _selected == status ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _selected == status
                                ? AppColors.primary
                                : Colors.white,
                            border: Border.all(
                                color: _selected == status
                                    ? AppColors.primary
                                    : AppColors.border,
                                width: 2),
                          ),
                          child: _selected == status
                              ? const Icon(Icons.check,
                                  size: 14, color: Colors.white)
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(status.label,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textDark)),
                              Text(status.description,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textMuted)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                    child: LabelValue(
                        label: 'Estimated cost',
                        value: formatRs(r.estimatedCost))),
                Expanded(
                    child: LabelValue(
                        label: 'Estimated time', value: r.estimatedTime ?? '-')),
              ],
            ),
            const SizedBox(height: 20),
            PrimaryButton(
              text: 'Update Status',
              onPressed: _canSave ? _save : null,
            ),
            const SizedBox(height: 8),
            Center(
              child: Text('Last updated: ${timeAgo(r.updatedAt)}',
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textMuted)),
            ),
          ],
        ),
      ),
    );
  }
}
