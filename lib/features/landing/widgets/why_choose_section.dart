import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/responsive_layout.dart';

class WhyChooseSection extends StatelessWidget {
  const WhyChooseSection({super.key});

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
        child: Column(
          children: [
            const Text(
              'THE SKILL-LINK ADVANTAGE',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryTeal,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Why Choose Skill-Link?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: AppColors.charcoal,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'We designed Skill-Link with integrity, fairness, and mutual respect at the center.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.secondaryGrey,
              ),
            ),
            const SizedBox(height: 40),

            LayoutBuilder(
              builder: (context, constraints) {
                int crossAxisCount = constraints.maxWidth > 800 ? 3 : (constraints.maxWidth > 550 ? 2 : 1);

                return GridView.count(
                  crossAxisCount: crossAxisCount,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  childAspectRatio: constraints.maxWidth > 800 ? 1.2 : 1.4,
                  children: const [
                    _BenefitCard(
                      icon: Icons.swap_horiz_rounded,
                      title: 'One Account, Two Roles',
                      description:
                          'Effortlessly switch between hiring professionals and offering your own skills without creating duplicate accounts.',
                    ),
                    _BenefitCard(
                      icon: Icons.money_off_csred_rounded,
                      title: 'Direct Negotiations',
                      description:
                          'Fair compensation without hidden platform cuts or predatory commissions taken from hard-working artisans.',
                    ),
                    _BenefitCard(
                      icon: Icons.verified_user_outlined,
                      title: 'Audited Reviews',
                      description:
                          'Ratings only from verified completed jobs. No artificial spam or self-promotional reviews.',
                    ),
                    _BenefitCard(
                      icon: Icons.location_on_outlined,
                      title: 'Hyperlocal Reach',
                      description:
                          'Find talent right in your neighborhood and locality for rapid response times and trusted familiarity.',
                    ),
                    _BenefitCard(
                      icon: Icons.photo_library_outlined,
                      title: 'Visual Portfolios',
                      description:
                          'Inspect real past project photos and verified work examples before making your hiring decision.',
                    ),
                    _BenefitCard(
                      icon: Icons.lock_outline_rounded,
                      title: 'Privacy By Design',
                      description:
                          'Your phone number and private contact info are safeguarded and only revealed upon authorized booking.',
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _BenefitCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _BenefitCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
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
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primaryTeal, size: 22),
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
          const SizedBox(height: 6),
          Expanded(
            child: Text(
              description,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.secondaryGrey,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

