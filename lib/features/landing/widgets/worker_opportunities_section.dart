import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/utils/responsive_layout.dart';
import '../../../core/widgets/app_button.dart';

class WorkerOpportunitiesSection extends StatelessWidget {
  const WorkerOpportunitiesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveLayout.isDesktop(context);

    return Container(
      width: double.infinity,
      color: AppColors.deepForestTeal,
      padding: EdgeInsets.symmetric(
        vertical: isDesktop ? 72 : 48,
        horizontal: 24,
      ),
      child: MaxWidthContainer(
        child: isDesktop ? _buildDesktopLayout(context) : _buildMobileLayout(context),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Left Column: Copy & Actions
        Expanded(
          flex: 6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryTeal,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'FOR SKILLED CRAFTSPEOPLE',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                    letterSpacing: 1,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Turn Your Craft Into A Thriving Independent Career',
                style: TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.w800,
                  color: AppColors.white,
                  letterSpacing: -0.5,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Skill-Link connects you directly with homeowners, businesses, and neighbors who value your expertise. Set your own pricing, build a verified reputation, and work on your own terms.',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.white.withAlpha((0.85 * 255).round()),
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 32),
              const Wrap(
                spacing: 24,
                runSpacing: 14,
                children: [
                  _PerkCheck(text: 'Direct Customer Bookings'),
                  _PerkCheck(text: 'Zero Commission Deduction'),
                  _PerkCheck(text: 'Build A Digital Portfolio'),
                  _PerkCheck(text: 'Instant Application Tracking'),
                ],
              ),
              const SizedBox(height: 36),
              AppButton(
                label: 'Start Earning With Skill-Link',
                icon: Icons.rocket_launch_rounded,
                onPressed: () => context.go(RouteNames.register),
                variant: AppButtonVariant.secondary,
              ),
            ],
          ),
        ),
        const SizedBox(width: 48),

        // Right Column: Visual card
        Expanded(
          flex: 5,
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: AppColors.white.withAlpha((0.08 * 255).round()),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppColors.white.withAlpha((0.15 * 255).round()),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.workspace_premium_rounded, color: AppColors.mutedSaffron, size: 28),
                    SizedBox(width: 12),
                    Text(
                      'Worker Growth Hub',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildMetricRow('Verified Profile', 'Stand out with skills, experience, and badges.'),
                const Divider(color: Colors.white24, height: 28),
                _buildMetricRow('Direct Payments', 'Customers pay you directly upon job completion.'),
                const Divider(color: Colors.white24, height: 28),
                _buildMetricRow('Customer Reviews', 'Every completed job adds to your rating score.'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primaryTeal,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'FOR SKILLED CRAFTSPEOPLE',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.white,
              letterSpacing: 1,
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Turn Your Craft Into A Thriving Career',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: AppColors.white,
            letterSpacing: -0.5,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Skill-Link connects you directly with neighbors who value your expertise. Set your own pricing and work on your own terms.',
          style: TextStyle(
            fontSize: 15,
            color: AppColors.white.withAlpha((0.85 * 255).round()),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 24),
        const _PerkCheck(text: 'Direct Customer Bookings'),
        const SizedBox(height: 12),
        const _PerkCheck(text: 'Zero Commission Deduction'),
        const SizedBox(height: 12),
        const _PerkCheck(text: 'Build A Digital Portfolio'),
        const SizedBox(height: 28),
        AppButton(
          label: 'Start Earning With Skill-Link',
          icon: Icons.rocket_launch_rounded,
          onPressed: () => context.go(RouteNames.register),
          isFullWidth: true,
          variant: AppButtonVariant.secondary,
        ),
      ],
    );
  }

  Widget _buildMetricRow(String title, String desc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.mutedSaffron,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          desc,
          style: TextStyle(
            color: AppColors.white.withAlpha((0.8 * 255).round()),
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

class _PerkCheck extends StatelessWidget {
  final String text;

  const _PerkCheck({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.check_circle_rounded, color: AppColors.mutedSaffron, size: 18),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
