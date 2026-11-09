import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/responsive_layout.dart';

class CommunityImpactSection extends StatelessWidget {
  const CommunityImpactSection({super.key});

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
              'LOCAL ECONOMIC EMPOWERMENT',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryTeal,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Building Stronger Communities Together',
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
              'Sample platform benchmarks highlighting our community-first marketplace design.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: AppColors.secondaryGrey,
              ),
            ),
            const SizedBox(height: 40),

            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 750;
                return isWide
                    ? const Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              number: '11+',
                              label: 'Service Domains',
                              subtext: 'From carpentry to tutoring',
                            ),
                          ),
                          SizedBox(width: 20),
                          Expanded(
                            child: _StatCard(
                              number: '100%',
                              label: 'Direct Earnings',
                              subtext: 'Zero platform commission taken',
                            ),
                          ),
                          SizedBox(width: 20),
                          Expanded(
                            child: _StatCard(
                              number: '1',
                              label: 'Unified Account',
                              subtext: 'Hire & work from one login',
                            ),
                          ),
                          SizedBox(width: 20),
                          Expanded(
                            child: _StatCard(
                              number: '24/7',
                              label: 'Neighborhood Access',
                              subtext: 'Direct local coordination',
                            ),
                          ),
                        ],
                      )
                    : const Column(
                        children: [
                          _StatCard(
                            number: '11+',
                            label: 'Service Domains',
                            subtext: 'From carpentry to tutoring',
                          ),
                          SizedBox(height: 16),
                          _StatCard(
                            number: '100%',
                            label: 'Direct Earnings',
                            subtext: 'Zero platform commission taken',
                          ),
                          SizedBox(height: 16),
                          _StatCard(
                            number: '1',
                            label: 'Unified Account',
                            subtext: 'Hire & work from one login',
                          ),
                          SizedBox(height: 16),
                          _StatCard(
                            number: '24/7',
                            label: 'Neighborhood Access',
                            subtext: 'Direct local coordination',
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

class _StatCard extends StatelessWidget {
  final String number;
  final String label;
  final String subtext;

  const _StatCard({
    required this.number,
    required this.label,
    required this.subtext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: AppColors.warmCream,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGrey, width: 1),
      ),
      child: Column(
        children: [
          Text(
            number,
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryTeal,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtext,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.secondaryGrey,
            ),
          ),
        ],
      ),
    );
  }
}

