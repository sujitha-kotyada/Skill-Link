import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/utils/responsive_layout.dart';
import '../../../core/widgets/app_button.dart';

class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveLayout.isDesktop(context);

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.warmCream,
        border: Border(bottom: BorderSide(color: AppColors.borderGrey, width: 1)),
      ),
      padding: EdgeInsets.symmetric(
        vertical: isDesktop ? 64 : 40,
        horizontal: 24,
      ),
      child: MaxWidthContainer(
        child: isDesktop ? _buildDesktopHero(context) : _buildMobileHero(context),
      ),
    );
  }

  Widget _buildDesktopHero(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Left Column: Text & CTAs
        Expanded(
          flex: 6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBadge(),
              const SizedBox(height: 20),
              const Text(
                AppStrings.heroHeadline,
                style: TextStyle(
                  fontSize: 44,
                  fontWeight: FontWeight.w800,
                  color: AppColors.charcoal,
                  height: 1.15,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                AppStrings.heroSubheadline,
                style: TextStyle(
                  fontSize: 18,
                  color: AppColors.secondaryGrey,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 36),
              Wrap(
                spacing: 16,
                runSpacing: 12,
                children: [
                  AppButton(
                    label: AppStrings.findSkilledWorkers,
                    icon: Icons.search_rounded,
                    onPressed: () => context.go(RouteNames.customerFindWorkers),
                    variant: AppButtonVariant.primary,
                  ),
                  AppButton(
                    label: AppStrings.offerYourSkills,
                    icon: Icons.handyman_outlined,
                    onPressed: () => context.go(RouteNames.login),
                    variant: AppButtonVariant.outlined,
                  ),
                ],
              ),
              const SizedBox(height: 32),
              _buildTrustPills(),
            ],
          ),
        ),
        const SizedBox(width: 48),

        // Right Column: Visual Showcase Card
        Expanded(
          flex: 5,
          child: _buildHeroVisual(),
        ),
      ],
    );
  }

  Widget _buildMobileHero(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBadge(),
        const SizedBox(height: 16),
        const Text(
          AppStrings.heroHeadline,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: AppColors.charcoal,
            height: 1.2,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          AppStrings.heroSubheadline,
          style: TextStyle(
            fontSize: 16,
            color: AppColors.secondaryGrey,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 28),
        AppButton(
          label: AppStrings.findSkilledWorkers,
          icon: Icons.search_rounded,
          onPressed: () => context.go(RouteNames.customerFindWorkers),
          isFullWidth: true,
          variant: AppButtonVariant.primary,
        ),
        const SizedBox(height: 12),
        AppButton(
          label: AppStrings.offerYourSkills,
          icon: Icons.handyman_outlined,
          onPressed: () => context.go(RouteNames.login),
          isFullWidth: true,
          variant: AppButtonVariant.outlined,
        ),
        const SizedBox(height: 28),
        _buildTrustPills(),
        const SizedBox(height: 32),
        _buildHeroVisual(),
      ],
    );
  }

  Widget _buildBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.tealSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryTeal.withAlpha((0.3 * 255).round())),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified_rounded, size: 16, color: AppColors.primaryTeal),
          SizedBox(width: 8),
          Text(
            'Verified Local Marketplace',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryTeal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrustPills() {
    return const Wrap(
      spacing: 20,
      runSpacing: 10,
      children: [
        _TrustItem(icon: Icons.check_circle_outline, text: 'No Middlemen Markup'),
        _TrustItem(icon: Icons.star_border_rounded, text: 'Community Reviewed'),
        _TrustItem(icon: Icons.shield_outlined, text: 'Direct Communication'),
      ],
    );
  }

  Widget _buildHeroVisual() {
    return Container(
      height: 380,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryTeal,
            AppColors.deepForestTeal,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderGrey, width: 1),
        boxShadow: [AppColors.elevatedShadow],
      ),
      child: Stack(
        children: [
          // Decorative background circles
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withAlpha((0.08 * 255).round()),
              ),
            ),
          ),
          Positioned(
            bottom: 60,
            left: -30,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withAlpha((0.05 * 255).round()),
              ),
            ),
          ),
          // Center Icon composition
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha((0.15 * 255).round()),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withAlpha((0.3 * 255).round()), width: 2),
                  ),
                  child: const Icon(Icons.handyman_rounded, color: AppColors.white, size: 48),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Community Artisans & Services',
                  style: TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Verified Local Network • 11+ Specialties',
                  style: TextStyle(
                    color: AppColors.white.withAlpha((0.8 * 255).round()),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          // Floating Worker Card Badge
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [AppColors.softShadow],
              ),
              child: const Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: AppColors.primaryTeal,
                    child: Icon(Icons.electrical_services, color: AppColors.white, size: 22),
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Ramesh Verma',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.charcoal,
                          ),
                        ),
                        Text(
                          'Master Electrician • 8 yrs exp',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.secondaryGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Icon(Icons.star_rounded, color: AppColors.mutedSaffron, size: 18),
                      SizedBox(width: 4),
                      Text(
                        '4.9',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrustItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _TrustItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.primaryTeal),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.charcoal,
          ),
        ),
      ],
    );
  }
}
