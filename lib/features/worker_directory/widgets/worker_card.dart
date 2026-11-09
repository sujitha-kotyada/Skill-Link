import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/rating_stars.dart';
import '../../../models/worker_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/customer_provider.dart';

class WorkerCard extends StatelessWidget {
  final WorkerModel worker;

  const WorkerCard({super.key, required this.worker});

  @override
  Widget build(BuildContext context) {
    final customerProvider = context.watch<CustomerProvider>();
    final authProvider = context.watch<AuthProvider>();
    final isSaved = customerProvider.isWorkerSaved(worker.uid);
    final currentUserId = authProvider.currentUser?.uid;

    return AppCard(
      padding: const EdgeInsets.all(20),
      onTap: () => context.push('/customer/workers/${worker.uid}', extra: worker),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppAvatar(
                name: worker.fullName,
                imageUrl: worker.photoUrl,
                radius: 26,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      worker.fullName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.charcoal,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${worker.category} • ${worker.experienceYears} yrs experience',
                      style: const TextStyle(fontSize: 12, color: AppColors.secondaryGrey),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 14, color: AppColors.secondaryGrey),
                        const SizedBox(width: 2),
                        Text(
                          worker.locationString,
                          style: const TextStyle(fontSize: 12, color: AppColors.secondaryGrey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (currentUserId != null && currentUserId != worker.uid)
                IconButton(
                  icon: Icon(
                    isSaved ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                    color: isSaved ? AppColors.terracotta : AppColors.secondaryGrey,
                  ),
                  onPressed: () {
                    customerProvider.toggleSaveWorker(
                      customerId: currentUserId,
                      workerId: worker.uid,
                    );
                  },
                ),
            ],
          ),
          const SizedBox(height: 14),

          // Headline
          Text(
            worker.headline,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.charcoal,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 10),

          // Skills Chips
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: worker.skills.take(3).map((skill) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.lightGrey,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  skill,
                  style: const TextStyle(fontSize: 11, color: AppColors.charcoal),
                ),
              );
            }).toList(),
          ),
          const Divider(height: 24),

          // Footer: Rating & Rate
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RatingStars(
                rating: worker.averageRating,
                reviewCount: worker.reviewCount,
                starSize: 15,
              ),
              Text(
                CurrencyFormatter.formatWithUnit(worker.rate, worker.rateType),
                style: const TextStyle(
                  fontSize: 16,
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

