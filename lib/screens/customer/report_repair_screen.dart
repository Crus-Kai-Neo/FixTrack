import 'package:flutter/material.dart';
import '../../models/shop.dart';
import '../../services/mock_service.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/primary_button.dart';

/// Figure 5 - FixTrack Report a Repair.
class ReportRepairScreen extends StatefulWidget {
  final Shop shop;

  const ReportRepairScreen({super.key, required this.shop});

  @override
  State<ReportRepairScreen> createState() => _ReportRepairScreenState();
}

class _ReportRepairScreenState extends State<ReportRepairScreen> {
  static const _deviceTypes = [
    'Smartphone',
    'Laptop',
    'Tablet',
    'Desktop',
    'Other'
  ];

  final _formKey = GlobalKey<FormState>();
  final _modelController = TextEditingController();
  final _problemController = TextEditingController();

  String? _deviceType;
  String? _typeError;
  late Shop _shop;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _shop = widget.shop;
  }

  @override
  void dispose() {
    _modelController.dispose();
    _problemController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final formOk = _formKey.currentState!.validate();
    setState(() =>
        _typeError = _deviceType == null ? 'Please select a device type' : null);
    if (!formOk || _deviceType == null) return;

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;

    final request = MockService.instance.submitRequest(
      deviceType: _deviceType!,
      deviceModel: _modelController.text.trim(),
      problem: _problemController.text.trim(),
      shop: _shop,
    );
    setState(() => _isLoading = false);

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Request sent'),
        content: Text(
            'Your reference number is ${request.id}.\n\n${_shop.name} will review your request and send you an estimate.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final shopNames = MockService.instance.shops.map((s) => s.name).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Report a Repair')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PickerField(
                  label: 'Device Type',
                  hint: 'Select device type',
                  value: _deviceType,
                  options: _deviceTypes,
                  errorText: _typeError,
                  onChanged: (v) => setState(() {
                    _deviceType = v;
                    _typeError = null;
                  }),
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Device Brand / Model',
                  hint: 'e.g. Dell Inspiron 15',
                  controller: _modelController,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Please enter the device brand or model'
                      : null,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Describe the Problem',
                  hint: 'Tell us what is wrong with your device...',
                  controller: _problemController,
                  maxLines: 5,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Please describe the problem';
                    }
                    if (v.trim().length < 10) {
                      return 'Please add a little more detail (10+ characters)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                PickerField(
                  label: 'Preferred Repair Shop',
                  hint: 'Select a repair shop',
                  value: _shop.name,
                  options: shopNames,
                  onChanged: (name) => setState(() => _shop = MockService
                      .instance.shops
                      .firstWhere((s) => s.name == name)),
                ),
                const SizedBox(height: 28),
                PrimaryButton(
                  text: 'Submit Request',
                  isLoading: _isLoading,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
