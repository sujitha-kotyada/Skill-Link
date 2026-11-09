import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/utils/responsive_layout.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../providers/auth_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.warmCream,
      appBar: AppBar(
        title: const Text('Settings & About', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: MaxWidthContainer(
            maxWidth: 680,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // App Branding Card
                AppCard(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.primaryTeal,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.handshake_rounded, color: AppColors.white, size: 32),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        AppStrings.appName,
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.charcoal),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppConstants.appTagline,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 14, color: AppColors.secondaryGrey),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.tealSurface,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Version 2.0.0 (Production Release)',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primaryTeal),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Platform Features & Ethics
                AppCard(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Platform Architecture',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.charcoal),
                      ),
                      const SizedBox(height: 16),
                      _buildFeatureTile(
                        icon: Icons.sync_rounded,
                        title: 'Unified Account Model',
                        desc: 'One login grants access to both customer and worker features without duplicating credentials.',
                      ),
                      const Divider(height: 20),
                      _buildFeatureTile(
                        icon: Icons.security_rounded,
                        title: 'Role-Based Firestore Security',
                        desc: 'Strict server-enforced rules guarantee data isolation and prevent unauthorized access or privilege escalation.',
                      ),
                      const Divider(height: 20),
                      _buildFeatureTile(
                        icon: Icons.monetization_on_outlined,
                        title: 'Direct Economic Fairness',
                        desc: 'Zero platform cuts taken from hard-working local artisans. Rates and agreements remain transparent.',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Support & Legal
                AppCard(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Legal & Community Guidelines',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.charcoal),
                      ),
                      const SizedBox(height: 12),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.policy_outlined, color: AppColors.secondaryGrey),
                        title: const Text('Terms of Service', style: TextStyle(fontSize: 14)),
                        trailing: const Icon(Icons.chevron_right, size: 20),
                        onTap: () {},
                      ),
                      const Divider(height: 1),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.privacy_tip_outlined, color: AppColors.secondaryGrey),
                        title: const Text('Privacy Policy', style: TextStyle(fontSize: 14)),
                        trailing: const Icon(Icons.chevron_right, size: 20),
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                AppButton(
                  label: 'Sign Out',
                  icon: Icons.logout_rounded,
                  onPressed: () async {
                    await authProvider.signOut();
                    if (context.mounted) context.go(RouteNames.login);
                  },
                  isFullWidth: true,
                  variant: AppButtonVariant.danger,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureTile({
    required IconData icon,
    required String title,
    required String desc,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.tealSurface,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primaryTeal, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.charcoal)),
              const SizedBox(height: 2),
              Text(desc, style: const TextStyle(fontSize: 12, color: AppColors.secondaryGrey, height: 1.4)),
            ],
          ),
        ),
      ],
    );
  }
}
