import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/utils/responsive_layout.dart';
import '../../../core/widgets/app_button.dart';

class FinalCtaSection extends StatelessWidget {
  const FinalCtaSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 24),
      child: MaxWidthContainer(
        maxWidth: 900,
        child: Container(
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: AppColors.tealSurface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.primaryTeal.withAlpha((0.3 * 255).round()),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              const Text(
                'Ready To Get Started?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: AppColors.deepForestTeal,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Join thousands of local neighbors discovering skills and building livelihood opportunities.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.secondaryGrey,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              Wrap(
                spacing: 16,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  AppButton(
                    label: 'Get Started Today',
                    icon: Icons.person_add_outlined,
                    onPressed: () => context.go(RouteNames.register),
                    variant: AppButtonVariant.primary,
                  ),
                  AppButton(
                    label: 'Sign In To Portal',
                    icon: Icons.login_rounded,
                    onPressed: () => context.go(RouteNames.login),
                    variant: AppButtonVariant.outlined,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LandingFooter extends StatelessWidget {
  const LandingFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.charcoal,
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: MaxWidthContainer(
        child: Column(
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 700) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Brand Column
                      Expanded(
                        flex: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryTeal,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.handshake_rounded,
                                    color: AppColors.white,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Text(
                                  AppStrings.appName,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.white,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Text(
                              AppConstants.appTagline,
                              style: TextStyle(
                                color: AppColors.white.withAlpha((0.7 * 255).round()),
                                fontSize: 14,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 32),

                      // Links Column 1: Navigation
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Navigation',
                              style: TextStyle(
                                color: AppColors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _FooterLink(label: 'Home', onTap: () => context.go(RouteNames.landing)),
                            _FooterLink(label: 'Find Workers', onTap: () => context.go(RouteNames.customerFindWorkers)),
                            _FooterLink(label: 'Sign In', onTap: () => context.go(RouteNames.login)),
                            _FooterLink(label: 'Get Started', onTap: () => context.go(RouteNames.register)),
                          ],
                        ),
                      ),

                      // Links Column 2: Popular Categories
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Top Skills',
                              style: TextStyle(
                                color: AppColors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _FooterLink(label: 'Electrician', onTap: () => context.go(RouteNames.customerFindWorkers)),
                            _FooterLink(label: 'Plumber', onTap: () => context.go(RouteNames.customerFindWorkers)),
                            _FooterLink(label: 'Carpenter', onTap: () => context.go(RouteNames.customerFindWorkers)),
                            _FooterLink(label: 'All Categories', onTap: () => context.go(RouteNames.customerFindWorkers)),
                          ],
                        ),
                      ),
                    ],
                  );
                } else {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.primaryTeal,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.handshake_rounded,
                              color: AppColors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            AppStrings.appName,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: AppColors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        AppConstants.appTagline,
                        style: TextStyle(
                          color: AppColors.white.withAlpha((0.7 * 255).round()),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Wrap(
                        spacing: 16,
                        runSpacing: 8,
                        children: [
                          _FooterLink(label: 'Home', onTap: () => context.go(RouteNames.landing)),
                          _FooterLink(label: 'Find Workers', onTap: () => context.go(RouteNames.customerFindWorkers)),
                          _FooterLink(label: 'Sign In', onTap: () => context.go(RouteNames.login)),
                          _FooterLink(label: 'Register', onTap: () => context.go(RouteNames.register)),
                        ],
                      ),
                    ],
                  );
                }
              },
            ),

            const SizedBox(height: 32),
            const Divider(color: Colors.white12),
            const SizedBox(height: 16),
            Text(
              '© 2026 Skill-Link Marketplace. All rights reserved. Built with community integrity.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.white.withAlpha((0.5 * 255).round()),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FooterLink extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _FooterLink({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: onTap,
        child: Text(
          label,
          style: TextStyle(
            color: AppColors.white.withAlpha((0.75 * 255).round()),
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

