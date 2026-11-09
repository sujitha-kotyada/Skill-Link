import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/utils/responsive_layout.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../providers/auth_provider.dart';

class AuthErrorScreen extends StatelessWidget {
  const AuthErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final status = authProvider.status;
    final errorMsg = authProvider.errorMessage;

    String title = 'Authentication Notice';
    String description = errorMsg ?? 'An error occurred while verifying your account.';
    IconData icon = Icons.info_outline_rounded;
    Color iconColor = AppColors.primaryTeal;

    if (status == AuthStatus.networkError) {
      title = 'Connection Problem';
      description = errorMsg ?? 'Unable to reach the database to retrieve your profile. Please check your connection and tap Retry.';
      icon = Icons.wifi_off_rounded;
      iconColor = AppColors.terracotta;
    } else if (status == AuthStatus.profileMissing) {
      title = 'Profile Not Found';
      description = errorMsg ?? 'Your login credentials are valid, but no matching user profile was found in the database.';
      icon = Icons.account_circle_outlined;
      iconColor = AppColors.mutedSaffron;
    } else if (status == AuthStatus.accountSuspended) {
      title = 'Account Suspended';
      description = errorMsg ?? 'Your account has been deactivated or suspended. Please contact support for assistance.';
      icon = Icons.block_rounded;
      iconColor = AppColors.errorRed;
    } else if (status == AuthStatus.permissionDenied) {
      title = 'Firestore Permissions Required';
      description = errorMsg ?? 'Database access was denied. The security rules in your Firebase Console must allow authenticated users to read and write their profile.';
      icon = Icons.security_rounded;
      iconColor = AppColors.errorRed;
    }

    return Scaffold(
      backgroundColor: AppColors.warmCream,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: MaxWidthContainer(
              maxWidth: 480,
              child: AppCard(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: iconColor.withAlpha((0.15 * 255).round()),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icon, size: 36, color: iconColor),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.charcoal,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      description,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.secondaryGrey,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),

                    if (status == AuthStatus.networkError ||
                        status == AuthStatus.profileMissing ||
                        status == AuthStatus.permissionDenied) ...[
                      AppButton(
                        label: 'Retry Connection',
                        icon: Icons.refresh_rounded,
                        isLoading: authProvider.isLoading,
                        onPressed: () async {
                          await authProvider.retryLoadProfile();
                          if (context.mounted && authProvider.isAuthenticated) {
                            context.go(authProvider.determineInitialRoute());
                          }
                        },
                        isFullWidth: true,
                        variant: AppButtonVariant.primary,
                      ),
                      const SizedBox(height: 14),
                    ],

                    AppButton(
                      label: 'Sign Out & Return to Login',
                      icon: Icons.logout_rounded,
                      onPressed: () async {
                        await authProvider.signOut();
                        if (context.mounted) {
                          context.go(RouteNames.login);
                        }
                      },
                      isFullWidth: true,
                      variant: AppButtonVariant.outlined,
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
