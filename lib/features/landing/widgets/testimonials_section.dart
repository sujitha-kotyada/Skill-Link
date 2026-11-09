import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/responsive_layout.dart';
import '../../../core/widgets/app_avatar.dart';

class TestimonialsSection extends StatelessWidget {
  const TestimonialsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveLayout.isDesktop(context);

    const testimonials = [
      _TestimonialData(
        quote:
            'Finding an experienced electrician on short notice was always stressful. On Skill-Link, I connected directly with a verified electrician in my sector. The work was done cleanly and billed transparently.',
        name: 'Ananya Deshmukh',
        role: 'Customer • Pune',
        avatarInitial: 'AD',
        rating: 5,
      ),
      _TestimonialData(
        quote:
            'Other apps take massive cuts from my daily earnings. With Skill-Link, I communicate directly with customers and receive the full agreed rate. My regular client base has doubled.',
        name: 'Rajesh K. Sharma',
        role: 'Worker (Plumbing) • Bengaluru',
        avatarInitial: 'RS',
        rating: 5,
      ),
      _TestimonialData(
        quote:
            'I love the one-account feature. I hired a painter for my home renovation last month, and this month I offered freelance CAD drafting services on the same profile.',
        name: 'Arjun Menon',
        role: 'Customer & Worker • Kochi',
        avatarInitial: 'AM',
        rating: 5,
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
              'VOICES FROM THE NEIGHBORHOOD',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryTeal,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'What Our Users Say',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: AppColors.charcoal,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.lightGrey,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Sample User Testimonials',
                style: TextStyle(fontSize: 11, color: AppColors.secondaryGrey, fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 40),

            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 850) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: testimonials
                        .map((t) => Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                child: _TestimonialCard(data: t),
                              ),
                            ))
                        .toList(),
                  );
                } else {
                  return Column(
                    children: testimonials
                        .map((t) => Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _TestimonialCard(data: t),
                            ))
                        .toList(),
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

class _TestimonialData {
  final String quote;
  final String name;
  final String role;
  final String avatarInitial;
  final int rating;

  const _TestimonialData({
    required this.quote,
    required this.name,
    required this.role,
    required this.avatarInitial,
    required this.rating,
  });
}

class _TestimonialCard extends StatelessWidget {
  final _TestimonialData data;

  const _TestimonialCard({required this.data});

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
            children: List.generate(
              data.rating,
              (index) => const Icon(Icons.star_rounded, color: AppColors.mutedSaffron, size: 18),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '"${data.quote}"',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.charcoal,
              height: 1.5,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              AppAvatar(name: data.name, radius: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.charcoal,
                      ),
                    ),
                    Text(
                      data.role,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.secondaryGrey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

