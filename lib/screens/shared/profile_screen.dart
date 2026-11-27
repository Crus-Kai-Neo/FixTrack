import 'package:flutter/material.dart';
import '../../services/mock_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/primary_button.dart';
import '../auth/login_screen.dart';

/// PROPOSED screen (not one of the 13 documented figures).
/// Shows basic account information and a log out button.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    final ok = await confirmDialog(
      context,
      title: 'Log out',
      message: 'Are you sure you want to log out?',
      confirmText: 'Log out',
      danger: true,
    );
    if (!ok || !context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        automaticallyImplyLeading: false,
      ),
      body: ListenableBuilder(
        listenable: MockService.instance,
        builder: (context, _) {
          final s = MockService.instance;
          final isCustomer = s.role == UserRole.customer;
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Center(child: InitialsAvatar(name: s.userName, radius: 40)),
              const SizedBox(height: 14),
              Center(
                child: Text(s.userName,
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryDark)),
              ),
              const SizedBox(height: 8),
              Center(
                child: StatusChip(
                    label: isCustomer ? 'Customer' : 'Repair Shop',
                    color: AppColors.primary),
              ),
              const SizedBox(height: 24),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LabelValue(label: 'Email', value: s.userEmail),
                    const SizedBox(height: 14),
                    LabelValue(
                        label: 'Account type',
                        value: isCustomer ? 'Customer' : 'Repair Shop'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                text: 'Log out',
                outlined: true,
                color: AppColors.error,
                onPressed: () => _logout(context),
              ),
            ],
          );
        },
      ),
    );
  }
}
