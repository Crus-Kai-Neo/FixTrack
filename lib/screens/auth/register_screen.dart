import 'package:flutter/material.dart';
import '../../services/mock_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/primary_button.dart';
import '../business/business_shell.dart';
import '../customer/customer_shell.dart';

/// Figure 2 - FixTrack Login/Registration (registration part).
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _isCustomer = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'This field is required' : null;

  String? _validatePhone(String? v) {
    if (v == null || v.trim().isEmpty) return 'Please enter your phone number';
    final ok = RegExp(r'^[0-9+\- ]{7,15}$').hasMatch(v.trim());
    return ok ? null : 'Enter a valid phone number';
  }

  String? _validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Please enter your email';
    final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim());
    return ok ? null : 'Enter a valid email address';
  }

  String? _validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'Please create a password';
    if (v.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  String? _validateConfirm(String? v) {
    if (v != _passwordController.text) return 'Passwords do not match';
    return null;
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    // TODO: replace with a real API call when the backend is ready.
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() => _isLoading = false);

    MockService.instance.login(
      _isCustomer ? UserRole.customer : UserRole.business,
      _emailController.text.trim(),
      name: _nameController.text.trim(),
    );

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) =>
            _isCustomer ? const CustomerShell() : const BusinessShell(),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RoleSelector(
                  isCustomer: _isCustomer,
                  onChanged: (v) => setState(() => _isCustomer = v),
                ),
                const SizedBox(height: 20),
                AppTextField(
                  label: _isCustomer ? 'Full Name' : 'Shop Name',
                  hint: _isCustomer ? 'Your full name' : 'Your shop name',
                  controller: _nameController,
                  validator: _required,
                ),
                if (!_isCustomer) ...[
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'Shop Address',
                    hint: 'e.g. New Road, Kathmandu',
                    controller: _addressController,
                    validator: _required,
                  ),
                ],
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Phone Number',
                  hint: '98XXXXXXXX',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  validator: _validatePhone,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Email',
                  hint: 'name@example.com',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: _validateEmail,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Password',
                  hint: 'At least 6 characters',
                  controller: _passwordController,
                  isPassword: true,
                  validator: _validatePassword,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Confirm Password',
                  hint: 'Re-enter your password',
                  controller: _confirmController,
                  isPassword: true,
                  validator: _validateConfirm,
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  text: 'Create Account',
                  isLoading: _isLoading,
                  onPressed: _register,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Demo mode: a new repair shop account shows the sample TechCare Repairs data.',
                  style: TextStyle(fontSize: 12, color: AppColors.textMuted),

                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
