import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/responsive_layout.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/rating_stars.dart';

class ExploreWorkersSection extends StatelessWidget {
  const ExploreWorkersSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveLayout.isDesktop(context);

    // Sample featured worker profiles for the landing showcase
    final sampleWorkers = [
      _FeaturedWorker(
        name: 'Sunil Sharma',
        category: 'Plumber',
        headline: 'Licensed Master Plumber & Pipe Fitter',
        experienceYears: 9,
        city: 'Bengaluru',
        rate: 450,
        rateType: 'hourly',
        rating: 4.9,
        reviews: 38,
        skills: ['Pipe Fitting', 'Water Heater', 'Drainage', 'Leak Detection'],
      ),
      _FeaturedWorker(
        name: 'Pooja Nair',
        category: 'Tutor',
        headline: 'Mathematics & Science Specialist',
        experienceYears: 6,
        city: 'Mumbai',
        rate: 600,
        rateType: 'hourly',
        rating: 4.8,
        reviews: 29,
        skills: ['Algebra', 'CBSE / ICSE', 'Physics', 'Exam Prep'],
      ),
      _FeaturedWorker(
        name: 'Vikram Joshi',
        category: 'Carpenter',
        headline: 'Custom Furniture & Wood Restorer',
        experienceYears: 12,
        city: 'Delhi NCR',
        rate: 500,
        rateType: 'hourly',
        rating: 5.0,
        reviews: 44,
        skills: ['Cabinet Making', 'Wood Polishing', 'Door Fitting', 'Repairs'],
      ),
    ];

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
              'TOP RATED LOCAL TALENT',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryTeal,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Explore Skilled Professionals',
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
              'Meet some of the dedicated craftspeople building our local communities.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.secondaryGrey,
              ),
            ),
            const SizedBox(height: 40),

            // Worker Cards
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 850) {
                  return Row(
                    children: sampleWorkers
                        .map((w) => Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                child: _WorkerFeaturedCard(worker: w),
                              ),
                            ))
                        .toList(),
                  );
                } else {
                  return Column(
                    children: sampleWorkers
                        .map((w) => Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _WorkerFeaturedCard(worker: w),
                            ))
                        .toList(),
                  );
                }
              },
            ),

            const SizedBox(height: 36),
            AppButton(
              label: 'View All Workers In Your City',
              icon: Icons.arrow_forward_rounded,
              onPressed: () => context.go(RouteNames.customerFindWorkers),
              variant: AppButtonVariant.primary,
            ),
          ],
        ),
      ),
    );
  }
}

class _FeaturedWorker {
  final String name;
  final String category;
  final String headline;
  final int experienceYears;
  final String city;
  final double rate;
  final String rateType;
  final double rating;
  final int reviews;
  final List<String> skills;

  const _FeaturedWorker({
    required this.name,
    required this.category,
    required this.headline,
    required this.experienceYears,
    required this.city,
    required this.rate,
    required this.rateType,
    required this.rating,
    required this.reviews,
    required this.skills,
  });
}

class _WorkerFeaturedCard extends StatelessWidget {
  final _FeaturedWorker worker;

  const _WorkerFeaturedCard({required this.worker});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderGrey, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppAvatar(name: worker.name, radius: 26),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      worker.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.charcoal,
                      ),
                    ),
                    Text(
                      '${worker.category} • ${worker.experienceYears} yrs exp',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.secondaryGrey,
                      ),
                    ),
                  ],
                ),
              ),
              RatingStars(
                rating: worker.rating,
                reviewCount: worker.reviews,
                starSize: 14,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            worker.headline,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: worker.skills.take(3).map((s) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.lightGrey,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  s,
                  style: const TextStyle(fontSize: 11, color: AppColors.secondaryGrey),
                ),
              );
            }).toList(),
          ),
          const Divider(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 14, color: AppColors.secondaryGrey),
                  const SizedBox(width: 4),
                  Text(
                    worker.city,
                    style: const TextStyle(fontSize: 13, color: AppColors.secondaryGrey),
                  ),
                ],
              ),
              Text(
                CurrencyFormatter.formatWithUnit(worker.rate, worker.rateType),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryTeal,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
