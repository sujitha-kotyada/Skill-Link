import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/responsive_layout.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/rating_stars.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../models/job_model.dart';
import '../../../models/worker_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/customer_provider.dart';
import '../../../providers/job_provider.dart';

class CustomerDashboardScreen extends StatefulWidget {
  const CustomerDashboardScreen({super.key});

  @override
  State<CustomerDashboardScreen> createState() => _CustomerDashboardScreenState();
}

class _CustomerDashboardScreenState extends State<CustomerDashboardScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final customerProvider = context.read<CustomerProvider>();
      final authProvider = context.read<AuthProvider>();
      customerProvider.fetchWorkers();
      if (authProvider.currentUser != null) {
        customerProvider.loadSavedWorkers(authProvider.currentUser!.uid);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleSearch() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      context.read<CustomerProvider>().setSearchQuery(query);
    }
    context.go(RouteNames.customerFindWorkers);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final customerProvider = context.watch<CustomerProvider>();
    final jobProvider = context.watch<JobProvider>();
    final user = authProvider.currentUser;

    return Scaffold(
      backgroundColor: AppColors.warmCream,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: MaxWidthContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Greeting & Header
                _buildHeader(user?.fullName ?? 'Valued Customer'),
                const SizedBox(height: 24),

                // Search Bar
                _buildSearchBar(),
                const SizedBox(height: 28),

                // Quick Action Cards
                _buildQuickActions(context),
                const SizedBox(height: 32),

                // Service Categories Scroll
                _buildCategories(context, customerProvider),
                const SizedBox(height: 36),

                // Customer's Active Jobs Snippet
                if (user != null) _buildMyJobsSection(context, jobProvider, user.uid),
                const SizedBox(height: 36),

                // Featured / Recommended Workers
                _buildRecommendedWorkers(context, customerProvider),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String name) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hello, $name 👋',
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: AppColors.charcoal,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'What service do you need help with today?',
          style: TextStyle(fontSize: 15, color: AppColors.secondaryGrey),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGrey),
        boxShadow: [AppColors.softShadow],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search by profession, skill or artisan name...',
          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primaryTeal),
          suffixIcon: IconButton(
            icon: const Icon(Icons.arrow_forward_rounded, color: AppColors.primaryTeal),
            onPressed: _handleSearch,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        onSubmitted: (_) => _handleSearch(),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;
        return isWide
            ? Row(
                children: [
                  Expanded(
                    child: _QuickActionCard(
                      icon: Icons.add_circle_outline_rounded,
                      title: 'Post a New Job',
                      subtitle: 'Describe requirements & receive quotes',
                      color: AppColors.primaryTeal,
                      onTap: () => context.push(RouteNames.customerPostJob),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _QuickActionCard(
                      icon: Icons.person_search_rounded,
                      title: 'Find Workers',
                      subtitle: 'Browse local profiles & ratings',
                      color: AppColors.deepForestTeal,
                      onTap: () => context.go(RouteNames.customerFindWorkers),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _QuickActionCard(
                      icon: Icons.bookmark_added_rounded,
                      title: 'Saved Workers',
                      subtitle: 'Quick access to favorite craftspeople',
                      color: AppColors.terracotta,
                      onTap: () => context.go(RouteNames.customerSavedWorkers),
                    ),
                  ),
                ],
              )
            : Column(
                children: [
                  _QuickActionCard(
                    icon: Icons.add_circle_outline_rounded,
                    title: 'Post a New Job',
                    subtitle: 'Describe requirements & receive quotes',
                    color: AppColors.primaryTeal,
                    onTap: () => context.push(RouteNames.customerPostJob),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _QuickActionCard(
                          icon: Icons.person_search_rounded,
                          title: 'Find Workers',
                          subtitle: 'Browse local profiles',
                          color: AppColors.deepForestTeal,
                          onTap: () => context.go(RouteNames.customerFindWorkers),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _QuickActionCard(
                          icon: Icons.bookmark_added_rounded,
                          title: 'Saved Workers',
                          subtitle: 'Favorites list',
                          color: AppColors.terracotta,
                          onTap: () => context.go(RouteNames.customerSavedWorkers),
                        ),
                      ),
                    ],
                  ),
                ],
              );
      },
    );
  }

  Widget _buildCategories(BuildContext context, CustomerProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Popular Categories',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.charcoal,
              ),
            ),
            TextButton(
              onPressed: () => context.go(RouteNames.customerFindWorkers),
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 48,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: AppConstants.serviceCategories.length,
            separatorBuilder: (context, index) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final cat = AppConstants.serviceCategories[index];
              return InkWell(
                onTap: () {
                  provider.setCategory(cat);
                  context.go(RouteNames.customerFindWorkers);
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderGrey),
                  ),
                  child: Row(
                    children: [
                      Icon(AppConstants.getCategoryIcon(cat), size: 18, color: AppColors.primaryTeal),
                      const SizedBox(width: 8),
                      Text(
                        cat,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.charcoal),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMyJobsSection(BuildContext context, JobProvider jobProvider, String customerId) {
    return StreamBuilder<List<JobModel>>(
      stream: jobProvider.streamCustomerJobs(customerId),
      builder: (context, snapshot) {
        final jobs = snapshot.data ?? [];
        if (jobs.isEmpty) {
          return const SizedBox.shrink();
        }

        final recentJobs = jobs.take(3).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Your Posted Jobs',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.charcoal,
                  ),
                ),
                TextButton(
                  onPressed: () => context.go(RouteNames.customerJobs),
                  child: const Text('Manage All Jobs'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recentJobs.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final job = recentJobs[index];
                return _CustomerJobSnippetCard(job: job);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildRecommendedWorkers(BuildContext context, CustomerProvider provider) {
    final workers = provider.workers.take(4).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recommended Local Workers',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.charcoal,
              ),
            ),
            TextButton(
              onPressed: () => context.go(RouteNames.customerFindWorkers),
              child: const Text('Explore Directory'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (provider.isLoadingWorkers)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            ),
          )
        else if (workers.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderGrey),
            ),
            child: const Center(
              child: Text(
                'No worker profiles found yet in your area.',
                style: TextStyle(color: AppColors.secondaryGrey),
              ),
            ),
          )
        else
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth > 700 ? 2 : 1;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: crossAxisCount == 2 ? 1.6 : 2.0,
                ),
                itemCount: workers.length,
                itemBuilder: (context, index) {
                  return _RecommendedWorkerCard(worker: workers[index]);
                },
              );
            },
          ),
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withAlpha((0.15 * 255).round()),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.charcoal),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12, color: AppColors.secondaryGrey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomerJobSnippetCard extends StatelessWidget {
  final JobModel job;

  const _CustomerJobSnippetCard({required this.job});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      onTap: () => context.push('/customer/jobs/${job.id}'),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    StatusBadge(status: job.status),
                    const SizedBox(width: 8),
                    Text(
                      job.category,
                      style: const TextStyle(fontSize: 12, color: AppColors.secondaryGrey, fontWeight: FontWeight.w500),
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
                  'Budget: ${CurrencyFormatter.format(job.budget)} • ${DateFormatter.timeAgo(job.createdAt)}',
                  style: const TextStyle(fontSize: 12, color: AppColors.secondaryGrey),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.tealSurface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${job.applicantCount} Proposals',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primaryTeal),
                ),
              ),
              const SizedBox(height: 6),
              const Icon(Icons.chevron_right_rounded, color: AppColors.secondaryGrey),
            ],
          ),
        ],
      ),
    );
  }
}

class _RecommendedWorkerCard extends StatelessWidget {
  final WorkerModel worker;

  const _RecommendedWorkerCard({required this.worker});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      onTap: () => context.push('/customer/workers/${worker.uid}', extra: worker),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              AppAvatar(name: worker.fullName, imageUrl: worker.photoUrl, radius: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      worker.fullName,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.charcoal),
                    ),
                    Text(
                      '${worker.category} • ${worker.city}',
                      style: const TextStyle(fontSize: 12, color: AppColors.secondaryGrey),
                    ),
                  ],
                ),
              ),
              RatingStars(rating: worker.averageRating, reviewCount: worker.reviewCount, starSize: 14),
            ],
          ),
          Text(
            worker.headline,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13, color: AppColors.charcoal),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                CurrencyFormatter.formatWithUnit(worker.rate, worker.rateType),
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.primaryTeal),
              ),
              const Text(
                'View Profile →',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primaryTeal),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
