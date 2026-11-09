import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/utils/responsive_layout.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/custom_snackbar.dart';
import '../../../providers/auth_provider.dart';

class RoleEnrollmentScreen extends StatefulWidget {
  final String targetRole;

  const RoleEnrollmentScreen({super.key, required this.targetRole});

  @override
  State<RoleEnrollmentScreen> createState() => _RoleEnrollmentScreenState();
}

class _RoleEnrollmentScreenState extends State<RoleEnrollmentScreen> {
  bool _isLoading = false;

  Future<void> _handleEnroll() async {
    setState(() => _isLoading = true);

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.enrollRole(widget.targetRole);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      CustomSnackBar.showSuccess(
        context,
        'Successfully added ${widget.targetRole == AppConstants.roleWorker ? "Worker" : "Customer"} capability!',
      );

      if (widget.targetRole == AppConstants.roleWorker) {
        context.go(RouteNames.workerOnboarding);
      } else {
        context.go(RouteNames.customerDashboard);
      }
    } else {
      final msg = authProvider.errorMessage ?? 'Failed to enroll in role.';
      CustomSnackBar.showError(context, msg);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWorker = widget.targetRole == AppConstants.roleWorker;
    final roleTitle = isWorker ? 'Worker Capability' : 'Customer Capability';
    final roleIcon = isWorker ? Icons.handyman_rounded : Icons.person_search_rounded;
    final roleColor = isWorker ? AppColors.terracotta : AppColors.primaryTeal;

    return Scaffold(
      backgroundColor: AppColors.warmCream,
      appBar: AppBar(
        title: Text('Enroll $roleTitle', style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: MaxWidthContainer(
              maxWidth: 520,
              child: AppCard(
                padding: const EdgeInsets.all(32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: roleColor.withAlpha((0.15 * 255).round()),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(roleIcon, size: 36, color: roleColor),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Activate $roleTitle',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.charcoal,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      isWorker
                          ? 'Expand your Skill-Link account to showcase your skills, discover client job posts, and earn locally.'
                          : 'Expand your Skill-Link account to post jobs and hire verified local artisans whenever you need.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.secondaryGrey,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.tealSurface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.check_circle_outline, color: AppColors.primaryTeal, size: 18),
                              SizedBox(width: 8),
                              Text(
                                'No duplicate accounts needed',
                                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.check_circle_outline, color: AppColors.primaryTeal, size: 18),
                              SizedBox(width: 8),
                              Text(
                                'Existing profile & bookmarks preserved',
                                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.check_circle_outline, color: AppColors.primaryTeal, size: 18),
                              SizedBox(width: 8),
                              Text(
                                'Seamless switching anytime',
                                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    AppButton(
                      label: 'Confirm & Activate Role',
                      icon: Icons.done_all_rounded,
                      isLoading: _isLoading,
                      onPressed: _handleEnroll,
                      isFullWidth: true,
                      variant: isWorker ? AppButtonVariant.secondary : AppButtonVariant.primary,
                    ),
                    const SizedBox(height: 16),
                    AppButton(
                      label: 'Cancel',
                      onPressed: () => context.pop(),
                      isFullWidth: true,
                      variant: AppButtonVariant.text,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

