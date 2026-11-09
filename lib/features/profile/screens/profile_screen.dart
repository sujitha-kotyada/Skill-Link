import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/responsive_layout.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/custom_snackbar.dart';
import '../../../providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _showEditProfileDialog(BuildContext context, String currentName, String? currentPhone) {
    final nameCtrl = TextEditingController(text: currentName);
    final phoneCtrl = TextEditingController(text: currentPhone ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Basic Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppTextField(controller: nameCtrl, label: 'Full Name'),
            const SizedBox(height: 16),
            AppTextField(controller: phoneCtrl, label: 'Phone Number', keyboardType: TextInputType.phone),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (nameCtrl.text.trim().isNotEmpty) {
                await context.read<AuthProvider>().updateProfile(
                      fullName: nameCtrl.text.trim(),
                      phone: phoneCtrl.text.trim(),
                    );
                if (ctx.mounted) Navigator.pop(ctx);
              }
            },
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context, String email) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Password'),
        content: Text('Send a secure password reset link to $email?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              await context.read<AuthProvider>().sendPasswordReset(email);
              if (ctx.mounted) {
                Navigator.pop(ctx);
                CustomSnackBar.showSuccess(context, 'Reset link sent to your email.');
              }
            },
            child: const Text('Send Reset Email'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: Text('Please sign in to view your profile.')));
    }

    final hasBothRoles = user.hasBothRoles;
    final otherRole = user.isCustomerActive ? AppConstants.roleWorker : AppConstants.roleCustomer;
    final otherRoleLabel = otherRole == AppConstants.roleWorker ? 'Worker' : 'Customer';

    return Scaffold(
      backgroundColor: AppColors.warmCream,
      appBar: AppBar(
        title: const Text('Account Profile', style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push(RouteNames.settings),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: MaxWidthContainer(
            maxWidth: 680,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // User Identity Card
                AppCard(
                  padding: const EdgeInsets.all(28),
                  child: Row(
                    children: [
                      AppAvatar(name: user.fullName, imageUrl: user.photoUrl, radius: 36),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.fullName,
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.charcoal),
                            ),
                            const SizedBox(height: 4),
                            Text(user.email, style: const TextStyle(fontSize: 14, color: AppColors.secondaryGrey)),
                            if (user.phone != null && user.phone!.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(user.phone!, style: const TextStyle(fontSize: 13, color: AppColors.secondaryGrey)),
                            ],
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              children: user.roles.map((r) {
                                final isCurrent = r == user.activeRole;
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isCurrent ? AppColors.primaryTeal : AppColors.tealSurface,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    r[0].toUpperCase() + r.substring(1),
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: isCurrent ? AppColors.white : AppColors.primaryTeal,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, color: AppColors.primaryTeal),
                        onPressed: () => _showEditProfileDialog(context, user.fullName, user.phone),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Portal & Role Switching Card
                AppCard(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Portal & Role Management',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.charcoal),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Active Interface: ${user.activeRole.toUpperCase()} PORTAL',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primaryTeal),
                      ),
                      const SizedBox(height: 18),

                      if (hasBothRoles) ...[
                        AppButton(
                          label: 'Switch to $otherRoleLabel Portal',
                          icon: Icons.swap_horiz_rounded,
                          onPressed: () async {
                            final res = await authProvider.switchPortal(otherRole);
                            if (context.mounted) {
                              if (res == 'success') {
                                if (otherRole == AppConstants.roleWorker) {
                                  context.go(RouteNames.workerDashboard);
                                } else {
                                  context.go(RouteNames.customerDashboard);
                                }
                              } else if (res == 'needs_worker_onboarding') {
                                context.go(RouteNames.workerOnboarding);
                              }
                            }
                          },
                          isFullWidth: true,
                          variant: AppButtonVariant.primary,
                        ),
                      ] else ...[
                        AppButton(
                          label: 'Add $otherRoleLabel Capability (Enable Dual Role)',
                          icon: Icons.add_circle_outline,
                          onPressed: () => context.push(RouteNames.roleEnroll, extra: otherRole),
                          isFullWidth: true,
                          variant: AppButtonVariant.secondary,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Account Information & Security
                AppCard(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Account & Security',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.charcoal),
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.calendar_month_outlined, color: AppColors.secondaryGrey),
                        title: const Text('Member Since', style: TextStyle(fontSize: 14)),
                        trailing: Text(
                          DateFormatter.formatDate(user.createdAt),
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.lock_reset_rounded, color: AppColors.secondaryGrey),
                        title: const Text('Change Password', style: TextStyle(fontSize: 14)),
                        trailing: const Icon(Icons.chevron_right, size: 20),
                        onTap: () => _showChangePasswordDialog(context, user.email),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.settings_outlined, color: AppColors.secondaryGrey),
                        title: const Text('App Settings & About', style: TextStyle(fontSize: 14)),
                        trailing: const Icon(Icons.chevron_right, size: 20),
                        onTap: () => context.push(RouteNames.settings),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // Sign Out Button
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
}
