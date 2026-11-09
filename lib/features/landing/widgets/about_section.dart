import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/responsive_layout.dart';

class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveLayout.isDesktop(context);

    return Container(
      width: double.infinity,
      color: AppColors.white,
      padding: EdgeInsets.symmetric(
        vertical: isDesktop ? 64 : 48,
        horizontal: 24,
      ),
      child: MaxWidthContainer(
        maxWidth: 1040,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.tealSurface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'COMMUNITY-FOCUSED MARKETPLACE',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryTeal,
                  letterSpacing: 1.1,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'What is Skill-Link?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: AppColors.charcoal,
                letterSpacing: -0.6,
              ),
            ),
            const SizedBox(height: 16),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: const Text(
                'Skill-Link is a community-focused local skills and employment marketplace that bridges the gap between everyday households needing reliable services and skilled independent craftspeople offering their professional trade.\n\nBuilt on trust, fair pricing, and mutual respect, Skill-Link empowers customers to discover neighborhood specialists while enabling workers to build an authentic professional reputation without platform commissions.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.secondaryGrey,
                  height: 1.6,
                ),
              ),
            ),
            const SizedBox(height: 40),
            if (isDesktop)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildPillarCard(
                      icon: Icons.people_outline_rounded,
                      title: 'Direct Local Connection',
                      description:
                          'Connect directly with local plumbers, electricians, carpenters, tutors, and mechanics in your neighborhood.',
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: _buildPillarCard(
                      icon: Icons.sync_alt_rounded,
                      title: 'One Unified Account',
                      description:
                          'A single login allows you to hire trusted talent and offer your own services with zero account friction.',
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: _buildPillarCard(
                      icon: Icons.verified_outlined,
                      title: 'Verified & Transparent',
                      description:
                          'Honest ratings, transparent hourly or fixed quotes in ₹ INR, and verified customer feedback on completed jobs.',
                    ),
                  ),
                ],
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildPillarCard(
                    icon: Icons.people_outline_rounded,
                    title: 'Direct Local Connection',
                    description:
                        'Connect directly with local plumbers, electricians, carpenters, tutors, and mechanics in your neighborhood.',
                  ),
                  const SizedBox(height: 16),
                  _buildPillarCard(
                    icon: Icons.sync_alt_rounded,
                    title: 'One Unified Account',
                    description:
                        'A single login allows you to hire trusted talent and offer your own services with zero account friction.',
                  ),
                  const SizedBox(height: 16),
                  _buildPillarCard(
                    icon: Icons.verified_outlined,
                    title: 'Verified & Transparent',
                    description:
                        'Honest ratings, transparent hourly or fixed quotes in ₹ INR, and verified customer feedback on completed jobs.',
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPillarCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.warmCream,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGrey, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.tealSurface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primaryTeal, size: 24),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.secondaryGrey,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
