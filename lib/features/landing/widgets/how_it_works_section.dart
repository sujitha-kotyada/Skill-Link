import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/responsive_layout.dart';

class HowItWorksSection extends StatelessWidget {
  const HowItWorksSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveLayout.isDesktop(context);

    return Container(
      width: double.infinity,
      color: AppColors.warmCream,
      padding: EdgeInsets.symmetric(
        vertical: isDesktop ? 64 : 48,
        horizontal: 24,
      ),
      child: MaxWidthContainer(
        child: Column(
          children: [
            const Text(
              'SIMPLE & TRANSPARENT',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryTeal,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'How Skill-Link Works',
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
              'A straightforward, respectful connection between local service seekers and skilled craftspeople.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.secondaryGrey,
              ),
            ),
            const SizedBox(height: 48),

            // 3 Steps
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 800) {
                  return const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _StepCard(
                          stepNumber: '01',
                          icon: Icons.search_rounded,
                          title: 'Find or Post',
                          description:
                              'Search verified local workers by skill, rating, and city—or post your job requirements in minutes.',
                        ),
                      ),
                      SizedBox(width: 24),
                      Expanded(
                        child: _StepCard(
                          stepNumber: '02',
                          icon: Icons.handshake_rounded,
                          title: 'Connect Directly',
                          description:
                              'Review applications, check portfolios and transparent rates, and finalize job details with zero middleman commissions.',
                        ),
                      ),
                      SizedBox(width: 24),
                      Expanded(
                        child: _StepCard(
                          stepNumber: '03',
                          icon: Icons.task_alt_rounded,
                          title: 'Complete & Review',
                          description:
                              'Get work done locally with confidence. Submit ratings and authentic feedback to empower the community.',
                        ),
                      ),
                    ],
                  );
                } else {
                  return const Column(
                    children: [
                      _StepCard(
                        stepNumber: '01',
                        icon: Icons.search_rounded,
                        title: 'Find or Post',
                        description:
                            'Search verified local workers by skill, rating, and city—or post your job requirements in minutes.',
                      ),
                      SizedBox(height: 20),
                      _StepCard(
                        stepNumber: '02',
                        icon: Icons.handshake_rounded,
                        title: 'Connect Directly',
                        description:
                            'Review applications, check portfolios and transparent rates, and finalize job details with zero middleman commissions.',
                      ),
                      SizedBox(height: 20),
                      _StepCard(
                        stepNumber: '03',
                        icon: Icons.task_alt_rounded,
                        title: 'Complete & Review',
                        description:
                            'Get work done locally with confidence. Submit ratings and authentic feedback to empower the community.',
                      ),
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  final String stepNumber;
  final IconData icon;
  final String title;
  final String description;

  const _StepCard({
    required this.stepNumber,
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderGrey, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.tealSurface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.primaryTeal, size: 24),
              ),
              Text(
                stepNumber,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryTeal.withAlpha((0.25 * 255).round()),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.secondaryGrey,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

