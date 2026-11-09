import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/responsive_layout.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/rating_stars.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../models/application_model.dart';
import '../../../models/job_model.dart';
import '../../../providers/application_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/worker_provider.dart';

class WorkerDashboardScreen extends StatefulWidget {
  const WorkerDashboardScreen({super.key});

  @override
  State<WorkerDashboardScreen> createState() => _WorkerDashboardScreenState();
}

class _WorkerDashboardScreenState extends State<WorkerDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final workerProvider = context.read<WorkerProvider>();
      final authProvider = context.read<AuthProvider>();
      if (authProvider.currentUser != null) {
        workerProvider.loadProfile(authProvider.currentUser!.uid);
        workerProvider.fetchAvailableJobs();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final workerProvider = context.watch<WorkerProvider>();
    final appProvider = context.watch<ApplicationProvider>();
    final user = authProvider.currentUser;
    final workerProfile = workerProvider.profile ?? authProvider.workerProfile;

    return Scaffold(
      backgroundColor: AppColors.warmCream,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: MaxWidthContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with Worker Name & Status
                _buildHeader(user?.fullName ?? 'Artisan', workerProfile),
                const SizedBox(height: 24),

                // Metrics / Statistics Row
                _buildMetrics(context, workerProfile, user?.uid, appProvider),
                const SizedBox(height: 32),

                // Quick Action Banner
                _buildQuickActionBanner(context),
                const SizedBox(height: 32),

                // Recent Opportunities / Available Jobs Snippet
                _buildAvailableJobsSnippet(context, workerProvider),
                const SizedBox(height: 36),

                // Applications Tracker Snippet
                if (user != null) _buildApplicationsTracker(context, appProvider, user.uid),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String name, dynamic profile) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome Back, $name 🛠️',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppColors.charcoal,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              profile != null
                  ? '${profile.category} • ${profile.city}'
                  : 'Ready to discover new local opportunities.',
              style: const TextStyle(fontSize: 14, color: AppColors.secondaryGrey),
            ),
          ],
        ),
        if (profile != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderGrey),
            ),
            child: RatingStars(
              rating: profile.averageRating,
              reviewCount: profile.reviewCount,
              starSize: 14,
            ),
          ),
      ],
    );
  }

  Widget _buildMetrics(
    BuildContext context,
    dynamic profile,
    String? workerId,
    ApplicationProvider appProvider,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 650;
        final baseRate = profile != null
            ? CurrencyFormatter.formatWithUnit(profile.rate, profile.rateType)
            : 'Not set';

        return StreamBuilder<List<ApplicationModel>>(
          stream: workerId != null ? appProvider.streamWorkerApplications(workerId) : null,
          builder: (context, snapshot) {
            final apps = snapshot.data ?? [];
            final pendingCount = apps.where((a) => a.isApplied || a.isUnderReview).length;
            final acceptedCount = apps.where((a) => a.isAccepted).length;

            final cards = [
              _MetricCard(
                title: 'Active Applications',
                value: pendingCount.toString(),
                icon: Icons.hourglass_top_rounded,
                color: AppColors.primaryTeal,
              ),
              _MetricCard(
                title: 'Accepted Opportunities',
                value: acceptedCount.toString(),
                icon: Icons.check_circle_outline_rounded,
                color: AppColors.successGreen,
              ),
              _MetricCard(
                title: 'Published Base Rate',
                value: baseRate,
                icon: Icons.payments_outlined,
                color: AppColors.terracotta,
              ),
            ];

            return isWide
                ? Row(
                    children: cards.map((c) => Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 6), child: c))).toList(),
                  )
                : Column(
                    children: cards.map((c) => Padding(padding: const EdgeInsets.only(bottom: 12), child: c)).toList(),
                  );
          },
        );
      },
    );
  }

  Widget _buildQuickActionBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFBE9E7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.terracotta.withAlpha((0.3 * 255).round())),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.terracotta,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.tune_rounded, color: AppColors.white, size: 22),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Keep Your Profile Up-to-Date',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.charcoal),
                ),
                Text(
                  'Update your working hours, locality, and rates anytime.',
                  style: TextStyle(fontSize: 12, color: AppColors.secondaryGrey),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          AppButton(
            label: 'Edit Profile',
            onPressed: () => context.go(RouteNames.workerEditProfile),
            variant: AppButtonVariant.secondary,
            height: 40,
          ),
        ],
      ),
    );
  }

  Widget _buildAvailableJobsSnippet(BuildContext context, WorkerProvider provider) {
    final jobs = provider.availableJobs.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Available Jobs For You',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.charcoal),
            ),
            TextButton(
              onPressed: () => context.go(RouteNames.workerBrowseJobs),
              child: const Text('Browse All Jobs'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (provider.isLoadingJobs)
          const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
        else if (jobs.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderGrey),
            ),
            child: const Center(
              child: Text(
                'No open jobs matching your category currently. Check back soon!',
                style: TextStyle(color: AppColors.secondaryGrey),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: jobs.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final job = jobs[index];
              return _AvailableJobCard(job: job);
            },
          ),
      ],
    );
  }

  Widget _buildApplicationsTracker(
    BuildContext context,
    ApplicationProvider appProvider,
    String workerId,
  ) {
    return StreamBuilder<List<ApplicationModel>>(
      stream: appProvider.streamWorkerApplications(workerId),
      builder: (context, snapshot) {
        final applications = snapshot.data ?? [];
        if (applications.isEmpty) return const SizedBox.shrink();

        final recent = applications.take(3).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'My Recent Proposals',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.charcoal),
                ),
                TextButton(
                  onPressed: () => context.go(RouteNames.workerApplications),
                  child: const Text('View All Applications'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recent.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final app = recent[index];
                return AppCard(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              app.jobTitle,
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Offered: ${CurrencyFormatter.format(app.proposedRate)} • ${DateFormatter.timeAgo(app.createdAt)}',
                              style: const TextStyle(fontSize: 12, color: AppColors.secondaryGrey),
                            ),
                          ],
                        ),
                      ),
                      StatusBadge(status: app.status),
                    ],
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withAlpha((0.15 * 255).round()),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.charcoal),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: const TextStyle(fontSize: 12, color: AppColors.secondaryGrey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AvailableJobCard extends StatelessWidget {
  final JobModel job;

  const _AvailableJobCard({required this.job});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(18),
      onTap: () => context.push('/worker/jobs/${job.id}', extra: job),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.tealSurface,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        job.category,
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primaryTeal),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${job.city}, ${job.location}',
                      style: const TextStyle(fontSize: 12, color: AppColors.secondaryGrey),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  job.title,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.charcoal),
                ),
                const SizedBox(height: 4),
                Text(
                  job.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13, color: AppColors.secondaryGrey),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                CurrencyFormatter.format(job.budget),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.primaryTeal),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => context.push('/worker/apply-job/${job.id}', extra: job),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.terracotta,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  minimumSize: const Size(80, 36),
                ),
                child: const Text('Apply', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
