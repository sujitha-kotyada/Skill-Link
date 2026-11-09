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
import '../../../core/widgets/custom_snackbar.dart';
import '../../../providers/auth_provider.dart';

class PortalSelectionScreen extends StatelessWidget {
  const PortalSelectionScreen({super.key});

  Future<void> _selectPortal(BuildContext context, String targetRole) async {
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.currentUser;

    if (user == null) {
      context.go(RouteNames.login);
      return;
    }

    // Check if user has this role
    if (!user.roles.contains(targetRole)) {
      // Prompt user to enroll
      context.push(RouteNames.roleEnroll, extra: targetRole);
      return;
    }

    final result = await authProvider.switchPortal(targetRole);
    if (!context.mounted) return;

    if (result == 'success') {
      if (targetRole == AppConstants.roleWorker) {
        context.go(RouteNames.workerDashboard);
      } else {
        context.go(RouteNames.customerDashboard);
      }
    } else if (result == 'needs_worker_onboarding') {
      context.go(RouteNames.workerOnboarding);
    } else {
      CustomSnackBar.showError(context, 'Unable to switch to requested portal.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    final hasCustomer = user?.roles.contains(AppConstants.roleCustomer) ?? false;
    final hasWorker = user?.roles.contains(AppConstants.roleWorker) ?? false;

    return Scaffold(
      backgroundColor: AppColors.warmCream,
      appBar: AppBar(
        title: const Text(
          'Choose Portal',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            tooltip: 'Sign Out',
            icon: const Icon(Icons.logout_rounded),
            onPressed: () async {
              await authProvider.signOut();
              if (context.mounted) context.go(RouteNames.login);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: MaxWidthContainer(
              maxWidth: 800,
              child: Column(
                children: [
                  // Branded Header (EcoCollect Inspired)
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.tealSurface,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(Icons.handshake_rounded, size: 36, color: AppColors.primaryTeal),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Welcome, ${user?.fullName ?? "to Skill-Link"}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: AppColors.charcoal,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Choose how you want to use Skill-Link today.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.secondaryGrey,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Portal Cards
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth > 650;
                      return isWide
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child: _buildCustomerCard(context, hasCustomer),
                                ),
                                const SizedBox(width: 24),
                                Expanded(
                                  child: _buildWorkerCard(context, hasWorker),
                                ),
                              ],
                            )
                          : Column(
                              children: [
                                _buildCustomerCard(context, hasCustomer),
                                const SizedBox(height: 20),
                                _buildWorkerCard(context, hasWorker),
                              ],
                            );
                    },
                  ),

                  const SizedBox(height: 36),
                  // Informational banner
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.borderGrey),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.info_outline, size: 18, color: AppColors.primaryTeal),
                        SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            'One account, two experiences. Switch anytime from your profile without re-logging.',
                            style: TextStyle(fontSize: 13, color: AppColors.secondaryGrey),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomerCard(BuildContext context, bool hasCustomer) {
    return AppCard(
      padding: const EdgeInsets.all(28),
      border: Border.all(color: AppColors.primaryTeal.withAlpha((0.3 * 255).round()), width: 1.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.tealSurface,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.person_search_rounded, color: AppColors.primaryTeal, size: 28),
                  ),
                  if (hasCustomer)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.tealSurface,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Active Capability',
                        style: TextStyle(color: AppColors.primaryTeal, fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                AppStrings.customerRoleTitle,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.charcoal,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                AppStrings.customerRoleDesc,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.secondaryGrey,
                  height: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          AppButton(
            label: hasCustomer ? 'Continue as Customer' : 'Enroll as Customer',
            icon: Icons.arrow_forward_rounded,
            onPressed: () => _selectPortal(context, AppConstants.roleCustomer),
            isFullWidth: true,
            variant: AppButtonVariant.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildWorkerCard(BuildContext context, bool hasWorker) {
    return AppCard(
      padding: const EdgeInsets.all(28),
      border: Border.all(color: AppColors.terracotta.withAlpha((0.3 * 255).round()), width: 1.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFBE9E7),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.handyman_rounded, color: AppColors.terracotta, size: 28),
                  ),
                  if (hasWorker)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFBE9E7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Active Capability',
                        style: TextStyle(color: AppColors.terracotta, fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                AppStrings.workerRoleTitle,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.charcoal,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                AppStrings.workerRoleDesc,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.secondaryGrey,
                  height: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          AppButton(
            label: hasWorker ? 'Continue as Worker' : 'Enroll as Worker',
            icon: Icons.arrow_forward_rounded,
            onPressed: () => _selectPortal(context, AppConstants.roleWorker),
            isFullWidth: true,
            variant: AppButtonVariant.secondary,
          ),
        ],
      ),
    );
  }
}

