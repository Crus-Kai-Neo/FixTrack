import 'package:flutter/material.dart';
import '../models/repair_request.dart';
import '../services/mock_service.dart';
import '../theme/app_colors.dart';

// ------------------------------------------------------------------ helpers

String timeAgo(DateTime t) {
  final diff = DateTime.now().difference(t);
  if (diff.inMinutes < 1) return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  return '${diff.inDays}d ago';
}

String formatRs(int? value) {
  if (value == null) return '-';
  final s = value.toString();
  final buffer = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buffer.write(',');
    buffer.write(s[i]);
  }
  return 'Rs. ${buffer.toString()}';
}

String initials(String name) {
  final parts =
      name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
  if (parts.isEmpty) return '?';
  if (parts.length == 1) return parts[0][0].toUpperCase();
  return (parts[0][0] + parts[1][0]).toUpperCase();
}

Color stageColor(RequestStage s) {
  switch (s) {
    case RequestStage.pending:
      return AppColors.warning;
    case RequestStage.accepted:
    case RequestStage.estimateSent:
      return AppColors.info;
    case RequestStage.estimateRejected:
    case RequestStage.rejected:
      return AppColors.error;
    case RequestStage.booked:
      return AppColors.primary;
  }
}

Color statusColor(RepairStatus? s) {
  switch (s) {
    case null:
      return AppColors.info;
    case RepairStatus.received:
      return AppColors.info;
    case RepairStatus.diagnosing:
      return AppColors.warning;
    case RepairStatus.repairing:
      return AppColors.primary;
    case RepairStatus.ready:
      return AppColors.success;
    case RepairStatus.collected:
      return AppColors.textMuted;
  }
}

Future<bool> confirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmText = 'Confirm',
  bool danger = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(confirmText,
              style: TextStyle(
                  color: danger ? AppColors.error : AppColors.primary)),
        ),
      ],
    ),
  );
  return result ?? false;
}

// ------------------------------------------------------------------ widgets

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
    if (onTap == null) return card;
    return GestureDetector(onTap: onTap, child: card);
  }
}

class LabelValue extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const LabelValue({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
        const SizedBox(height: 2),
        Text(value,
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: valueColor ?? AppColors.textDark)),
      ],
    );
  }
}

class StatusChip extends StatelessWidget {
  final String label;
  final Color color;

  const StatusChip({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Color.alphaBlend(color.withAlpha(28), Colors.white),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w600, color: color)),
    );
  }
}

/// Chip that shows the right label for a request:
/// the workflow stage before booking, the repair status after booking.
class RequestChip extends StatelessWidget {
  final RepairRequest request;

  const RequestChip({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    if (request.isBooked) {
      final s = request.status;
      return StatusChip(
          label: s == null ? 'Booked' : s.label, color: statusColor(s));
    }
    return StatusChip(
        label: request.stage.label, color: stageColor(request.stage));
  }
}

class InitialsAvatar extends StatelessWidget {
  final String name;
  final double radius;

  const InitialsAvatar({super.key, required this.name, this.radius = 22});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.primarySoft,
      child: Text(initials(name),
          style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
              fontSize: radius * 0.7)),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionText;
  final VoidCallback? onAction;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryDark)),
          if (actionText != null)
            GestureDetector(
              onTap: onAction,
              child: Text(actionText!,
                  style: const TextStyle(
                      color: AppColors.primary, fontWeight: FontWeight.w600)),
            ),
        ],
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;

  const EmptyState({super.key, required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: AppColors.textMuted),
            const SizedBox(height: 12),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }
}

class ChipRow extends StatelessWidget {
  final List<String> labels;
  final int selected;
  final ValueChanged<int> onSelected;

  const ChipRow({
    super.key,
    required this.labels,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: labels.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final on = i == selected;
          return GestureDetector(
            onTap: () => onSelected(i),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: on ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border:
                    Border.all(color: on ? AppColors.primary : AppColors.border),
              ),
              child: Text(labels[i],
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: on ? Colors.white : AppColors.textDark)),
            ),
          );
        },
      ),
    );
  }
}

class RoleSelector extends StatelessWidget {
  final bool isCustomer;
  final ValueChanged<bool> onChanged;

  const RoleSelector({
    super.key,
    required this.isCustomer,
    required this.onChanged,
  });

  Widget _tab(String label, bool selected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : AppColors.primaryDark,
                )),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _tab('Customer', isCustomer, () => onChanged(true)),
          _tab('Repair Shop', !isCustomer, () => onChanged(false)),
        ],
      ),
    );
  }
}

/// A tappable field that opens a bottom sheet list (a simple dropdown).
class PickerField extends StatelessWidget {
  final String label;
  final String hint;
  final String? value;
  final List<String> options;
  final ValueChanged<String> onChanged;
  final String? errorText;

  const PickerField({
    super.key,
    required this.label,
    required this.hint,
    required this.value,
    required this.options,
    required this.onChanged,
    this.errorText,
  });

  Future<void> _open(BuildContext context) async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(label,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700)),
              ),
              for (final o in options)
                ListTile(
                  title: Text(o),
                  trailing: o == value
                      ? const Icon(Icons.check, color: AppColors.primary)
                      : null,
                  onTap: () => Navigator.pop(ctx, o),
                ),
            ],
          ),
        ),
      ),
    );
    if (picked != null) onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _open(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: hasError ? AppColors.error : AppColors.border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(value ?? hint,
                      style: TextStyle(
                          color: value == null
                              ? AppColors.textMuted
                              : AppColors.textDark)),
                ),
                const Icon(Icons.keyboard_arrow_down_rounded,
                    color: AppColors.textMuted),
              ],
            ),
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Text(errorText!,
                style: const TextStyle(color: AppColors.error, fontSize: 12)),
          ),
      ],
    );
  }
}

/// Vertical step list used for the 5 repair statuses.
/// currentIndex: -1 = nothing started, 0..4 = current step,
/// steps.length = everything finished.
class ProgressStepper extends StatelessWidget {
  final List<String> steps;
  final int currentIndex;

  const ProgressStepper({
    super.key,
    required this.steps,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(steps.length, (i) {
        final done = i < currentIndex;
        final current = i == currentIndex;
        final last = i == steps.length - 1;
        final subtitle =
            done ? 'Completed' : (current ? 'Current status' : 'Upcoming');

        Widget? inner;
        if (done) {
          inner = const Icon(Icons.check, size: 14, color: Colors.white);
        } else if (current) {
          inner = Center(
            child: Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                  shape: BoxShape.circle, color: AppColors.primary),
            ),
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: done ? AppColors.primary : Colors.white,
                    border: Border.all(
                        color: (done || current)
                            ? AppColors.primary
                            : AppColors.border,
                        width: 2),
                  ),
                  child: inner,
                ),
                if (!last)
                  Container(
                      width: 2,
                      height: 30,
                      color: done ? AppColors.primary : AppColors.border),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(steps[i],
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: (done || current)
                                ? AppColors.textDark
                                : AppColors.textMuted)),
                    Text(subtitle,
                        style: TextStyle(
                            fontSize: 12,
                            color: current
                                ? AppColors.primary
                                : AppColors.textMuted)),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

class NotificationBell extends StatelessWidget {
  final VoidCallback onTap;

  const NotificationBell({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: MockService.instance,
      builder: (context, _) {
        final count = MockService.instance.unreadCount;
        return IconButton(
          onPressed: onTap,
          icon: Badge(
            isLabelVisible: count > 0,
            label: Text('$count'),
            child: const Icon(Icons.notifications_none_rounded,
                color: AppColors.textDark),
          ),
        );
      },
    );
  }
}
