import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/responsive_layout.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/rating_stars.dart';
import '../../../models/review_model.dart';
import '../../../models/worker_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/customer_provider.dart';
import '../../../repositories/review_repository.dart';
import '../../../repositories/worker_repository.dart';

class WorkerDetailScreen extends StatefulWidget {
  final String workerId;
  final WorkerModel? initialWorker;

  const WorkerDetailScreen({
    super.key,
    required this.workerId,
    this.initialWorker,
  });

  @override
  State<WorkerDetailScreen> createState() => _WorkerDetailScreenState();
}

class _WorkerDetailScreenState extends State<WorkerDetailScreen> {
  WorkerModel? _worker;
  bool _isLoading = false;
  final _reviewRepository = ReviewRepository();
  final _workerRepository = WorkerRepository();

  @override
  void initState() {
    super.initState();
    _worker = widget.initialWorker;
    if (_worker == null) {
      _loadWorker();
    }
  }

  Future<void> _loadWorker() async {
    setState(() => _isLoading = true);
    try {
      final w = await _workerRepository.getWorkerProfile(widget.workerId);
      if (mounted) {
        setState(() {
          _worker = w;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showContactDialog() {
    if (_worker == null) return;
    final phone = _worker!.contactPhone ?? 'Direct messaging through job booking';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.phone_in_talk_rounded, color: AppColors.primaryTeal),
            const SizedBox(width: 10),
            Text('Contact ${_worker!.fullName}'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Official Service Contact:',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.secondaryGrey),
            ),
            const SizedBox(height: 8),
            SelectableText(
              phone,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.charcoal),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.tealSurface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Skill-Link protects your privacy. Please use contact details exclusively for scheduling and service details.',
                style: TextStyle(fontSize: 12, color: AppColors.deepForestTeal),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final customerProvider = context.watch<CustomerProvider>();
    final authProvider = context.watch<AuthProvider>();
    final currentUserId = authProvider.currentUser?.uid;

    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.warmCream,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_worker == null) {
      return Scaffold(
        backgroundColor: AppColors.warmCream,
        appBar: AppBar(),
        body: const Center(
          child: Text('Worker profile not found.'),
        ),
      );
    }

    final worker = _worker!;
    final isSaved = customerProvider.isWorkerSaved(worker.uid);

    return Scaffold(
      backgroundColor: AppColors.warmCream,
      appBar: AppBar(
        title: Text(worker.fullName, style: const TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          if (currentUserId != null && currentUserId != worker.uid)
            IconButton(
              icon: Icon(
                isSaved ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                color: isSaved ? AppColors.terracotta : AppColors.charcoal,
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: MaxWidthContainer(
            maxWidth: 900,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Header Card
                AppCard(
                  padding: const EdgeInsets.all(28),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppAvatar(name: worker.fullName, imageUrl: worker.photoUrl, radius: 40),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    worker.fullName,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.charcoal,
                                    ),
                                  ),
                                ),
                                RatingStars(
                                  rating: worker.averageRating,
                                  reviewCount: worker.reviewCount,
                                  starSize: 18,
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              worker.headline,
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.charcoal),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 14,
                              runSpacing: 6,
                              children: [
                                _InfoTag(icon: Icons.category_outlined, text: worker.category),
                                _InfoTag(icon: Icons.history_rounded, text: '${worker.experienceYears} Years Exp'),
                                _InfoTag(icon: Icons.location_on_outlined, text: worker.locationString),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Rate & Availability Banner Card
                AppCard(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Service Rate', style: TextStyle(fontSize: 12, color: AppColors.secondaryGrey)),
                          const SizedBox(height: 2),
                          Text(
                            CurrencyFormatter.formatWithUnit(worker.rate, worker.rateType),
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.primaryTeal),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('Availability', style: TextStyle(fontSize: 12, color: AppColors.secondaryGrey)),
                          const SizedBox(height: 2),
                          Text(
                            worker.availability,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.charcoal),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Action Buttons: Contact & Hire
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        label: 'Post a Job / Request',
                        icon: Icons.add_circle_outline,
                        onPressed: () => context.push(RouteNames.customerPostJob),
                        variant: AppButtonVariant.primary,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: AppButton(
                        label: 'Contact Worker',
                        icon: Icons.phone_outlined,
                        onPressed: _showContactDialog,
                        variant: AppButtonVariant.outlined,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // About & Bio Section
                AppCard(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'About The Professional',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.charcoal),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        worker.description,
                        style: const TextStyle(fontSize: 15, color: AppColors.charcoal, height: 1.6),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Skills & Specialties',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.charcoal),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: worker.skills.map((s) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.tealSurface,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              s,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primaryTeal),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // Community Reviews Section
                AppCard(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Client Reviews & Ratings',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.charcoal),
                          ),
                          RatingStars(rating: worker.averageRating, reviewCount: worker.reviewCount),
                        ],
                      ),
                      const SizedBox(height: 16),
                      StreamBuilder<List<ReviewModel>>(
                        stream: _reviewRepository.streamWorkerReviews(worker.uid),
                        builder: (context, snapshot) {
                          final reviews = snapshot.data ?? [];
                          if (reviews.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 24),
                              child: Center(
                                child: Text(
                                  'No reviews yet for this professional. Be the first to hire and review!',
                                  style: TextStyle(color: AppColors.secondaryGrey),
                                ),
                              ),
                            );
                          }

                          return ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: reviews.length,
                            separatorBuilder: (context, index) => const Divider(height: 24),
                            itemBuilder: (context, index) {
                              final rev = reviews[index];
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        rev.customerName,
                                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                                      ),
                                      Text(
                                        DateFormatter.formatDate(rev.createdAt),
                                        style: const TextStyle(fontSize: 12, color: AppColors.secondaryGrey),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: List.generate(
                                      rev.rating.toInt(),
                                      (_) => const Icon(Icons.star_rounded, size: 16, color: AppColors.mutedSaffron),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    rev.comment,
                                    style: const TextStyle(fontSize: 14, color: AppColors.charcoal, height: 1.4),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoTag extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoTag({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.secondaryGrey),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 12, color: AppColors.secondaryGrey)),
      ],
    );
  }
}
