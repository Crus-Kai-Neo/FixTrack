import 'package:flutter/material.dart';
import '../../models/repair_request.dart';
import '../../services/mock_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/primary_button.dart';

/// Figure 12 - FixTrack Send Estimate.
class SendEstimateScreen extends StatefulWidget {
  final RepairRequest request;

  const SendEstimateScreen({super.key, required this.request});

  @override
  State<SendEstimateScreen> createState() => _SendEstimateScreenState();
}

class _SendEstimateScreenState extends State<SendEstimateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _costController = TextEditingController();
  final _timeController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _costController.dispose();
    _timeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _send() {
    if (!_formKey.currentState!.validate()) return;
    final cost = int.parse(_costController.text.trim());
    MockService.instance.sendEstimate(
      widget.request,
      cost,
      _timeController.text.trim(),
      _notesController.text.trim(),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Estimate sent to the customer')),
    );
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.request;
    return Scaffold(
      appBar: AppBar(title: const Text('Send Estimate')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                const Text('Create Estimate',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryDark)),
                const SizedBox(height: 14),
                AppTextField(
                  label: 'Repair cost (NPR)',
                  hint: 'e.g. 5000',
                  prefixText: 'Rs. ',
                  controller: _costController,
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    final value = int.tryParse((v ?? '').trim());
                    if (value == null || value <= 0) {
                      return 'Enter a valid cost (numbers only)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Estimated time',
                  hint: 'e.g. 2 days',
                  controller: _timeController,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Please enter the estimated time'
                      : null,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Notes (optional)',
                  hint: 'Anything the customer should know...',
                  controller: _notesController,
                  maxLines: 4,
                ),
                const SizedBox(height: 8),
                const Text('The customer can review and accept your estimate.',
                    style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                const SizedBox(height: 20),
                PrimaryButton(text: 'Send Estimate', onPressed: _send),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
