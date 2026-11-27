import 'package:flutter/material.dart';
import '../models/repair_request.dart';
import '../theme/app_colors.dart';
import 'common_widgets.dart';
import 'primary_button.dart';

/// Card used on the business side (dashboard, requests, repair lists).
class ShopRequestCard extends StatelessWidget {
  final RepairRequest request;
  final String buttonText;
  final VoidCallback onPressed;
  final bool showEstimate;

  const ShopRequestCard({
    super.key,
    required this.request,
    required this.buttonText,
    required this.onPressed,
    this.showEstimate = false,
  });

  @override
  Widget build(BuildContext context) {
    final r = request;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
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
            Text(r.customerName,
                style: const TextStyle(
                    fontSize: 14, color: AppColors.textDark)),
            Text(r.problem,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 13, color: AppColors.textMuted)),
            if (showEstimate && r.estimatedCost != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                      child: LabelValue(
                          label: 'Estimated cost',
                          value: formatRs(r.estimatedCost))),
                  Expanded(
                      child: LabelValue(
                          label: 'Estimated time',
                          value: r.estimatedTime ?? '-')),
                ],
              ),
            ],
            const SizedBox(height: 14),
            PrimaryButton(
                text: buttonText, outlined: true, onPressed: onPressed),
          ],
        ),
      ),
    );
  }
}
