import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/utils/responsive_layout.dart';

class LandingHeader extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onHomeTap;
  final VoidCallback? onCategoriesTap;
  final VoidCallback? onHowItWorksTap;
  final VoidCallback? onAboutTap;
  final VoidCallback? onFindWorkersTap;

  const LandingHeader({
    super.key,
    this.onHomeTap,
    this.onCategoriesTap,
    this.onHowItWorksTap,
    this.onAboutTap,
    this.onFindWorkersTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveLayout.isDesktop(context);

    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: AppColors.warmCream.withAlpha((0.95 * 255).round()),
        border: const Border(
          bottom: BorderSide(color: AppColors.borderGrey, width: 1),
        ),
      ),
      child: MaxWidthContainer(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Logo & Brand Name
            InkWell(
              onTap: onHomeTap ?? () => context.go(RouteNames.landing),
              borderRadius: BorderRadius.circular(8),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primaryTeal,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.handshake_rounded,
                      color: AppColors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    AppStrings.appName,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.deepForestTeal,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),

            // Desktop Nav Links
            if (isDesktop)
              Flexible(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _NavLink(label: 'Home', onTap: onHomeTap ?? () => context.go(RouteNames.landing)),
                      const SizedBox(width: 18),
                      _NavLink(
                        label: 'Categories',
                        onTap: onCategoriesTap,
                      ),
                      const SizedBox(width: 18),
                      _NavLink(label: 'How It Works', onTap: onHowItWorksTap),
                      const SizedBox(width: 18),
                      _NavLink(label: 'About', onTap: onAboutTap),
                      const SizedBox(width: 20),
                      TextButton(
                        onPressed: () => context.go(RouteNames.login),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.deepForestTeal,
                          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                        child: const Text('Sign In'),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () => context.go(RouteNames.register),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryTeal,
                          foregroundColor: AppColors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Get Started'),
                      ),
                    ],
                  ),
                ),
              )
            else
              // Mobile Actions
              Row(
                children: [
                  TextButton(
                    onPressed: () => context.go(RouteNames.login),
                    child: const Text('Sign In', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.menu_rounded, color: AppColors.charcoal),
                    onPressed: () {
                      Scaffold.of(context).openEndDrawer();
                    },
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _NavLink extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const _NavLink({required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: AppColors.charcoal,
          ),
        ),
      ),
    );
  }
}
