import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/responsive_layout.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../models/job_model.dart';
import '../../../models/worker_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/worker_provider.dart';

class BrowseJobsScreen extends StatefulWidget {
  const BrowseJobsScreen({super.key});

  @override
  State<BrowseJobsScreen> createState() => _BrowseJobsScreenState();
}

class _BrowseJobsScreenState extends State<BrowseJobsScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<WorkerProvider>();
      _searchController.text = p.searchQuery;
      p.fetchAvailableJobs();
      p.fetchRecommendedJobs();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  WorkerModel? _tryGetAuthWorkerProfile(BuildContext context) {
    try {
      return Provider.of<AuthProvider>(context).workerProfile;
    } catch (_) {
      return null;
    }
  }

  void _openFilterDialog() {
    final p = context.read<WorkerProvider>();
    double minBudget = p.minBudget ?? 0;
    String selectedCity = p.selectedCity;
    String sortBy = p.sortBy;
    final cityCtrl = TextEditingController(text: selectedCity);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Filter Open Jobs', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                  TextButton(
                    onPressed: () {
                      _searchController.clear();
                      p.clearJobFilters();
                      Navigator.pop(ctx);
                      setState(() {});
                    },
                    child: const Text('Reset'),
                  ),
                ],
              ),
              const Divider(height: 20),
              const Text('Filter by City / Location', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              const SizedBox(height: 8),
              TextField(
                controller: cityCtrl,
                decoration: const InputDecoration(hintText: 'e.g. Bengaluru, Mumbai'),
                onChanged: (val) => selectedCity = val,
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Minimum Budget (₹)', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                  Text(
                    minBudget > 0 ? '₹${minBudget.toInt()}' : 'Any',
                    style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primaryTeal),
                  ),
                ],
              ),
              Slider(
                value: minBudget.clamp(0, 10000),
                min: 0,
                max: 10000,
                divisions: 100,
                activeColor: AppColors.primaryTeal,
                onChanged: (val) => setSheetState(() => minBudget = val),
              ),
              const SizedBox(height: 12),
              const Text('Sort By', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('Newest'),
                    selected: sortBy == 'newest',
                    onSelected: (_) => setSheetState(() => sortBy = 'newest'),
                  ),
                  ChoiceChip(
                    label: const Text('Highest Budget'),
                    selected: sortBy == 'budget_desc',
                    onSelected: (_) => setSheetState(() => sortBy = 'budget_desc'),
                  ),
                  ChoiceChip(
                    label: const Text('Lowest Budget'),
                    selected: sortBy == 'budget_asc',
                    onSelected: (_) => setSheetState(() => sortBy = 'budget_asc'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              AppButton(
                label: 'Apply Filters',
                onPressed: () {
                  p.setJobFilters(
                    city: cityCtrl.text.trim(),
                    minBudget: minBudget > 0 ? minBudget : null,
                    sortBy: sortBy,
                  );
                  Navigator.pop(ctx);
                },
                isFullWidth: true,
                variant: AppButtonVariant.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final workerProvider = context.watch<WorkerProvider>();
    final workerProfile = workerProvider.profile ?? _tryGetAuthWorkerProfile(context);
    final jobs = workerProvider.availableJobs;
    final isSearching = workerProvider.isSearching;

    return Scaffold(
      backgroundColor: AppColors.warmCream,
      appBar: AppBar(
        title: const Text('Browse Available Jobs', style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded, color: AppColors.terracotta),
            onPressed: _openFilterDialog,
          ),
        ],
      ),
      body: SafeArea(
        child: MaxWidthContainer(
          child: Column(
            children: [
              const SizedBox(height: 16),
              // Search & Filter Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.borderGrey),
                        ),
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search jobs by title, category, or skill...',
                            prefixIcon: const Icon(Icons.search_rounded, size: 20),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    tooltip: 'Clear search',
                                    icon: const Icon(Icons.clear_rounded, size: 18),
                                    onPressed: () {
                                      _searchController.clear();
                                      workerProvider.clearSearchQuery();
                                      setState(() {});
                                    },
                                  )
                                : null,
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                          onChanged: (val) {
                            setState(() {});
                            workerProvider.setJobSearchQuery(val);
                          },
                          onSubmitted: (val) => workerProvider.setJobSearchQuery(val),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    InkWell(
                      onTap: _openFilterDialog,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFBE9E7),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.terracotta.withAlpha((0.3 * 255).round())),
                        ),
                        child: const Icon(Icons.tune_rounded, color: AppColors.terracotta, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Category Filter Pills
              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: 1 + AppConstants.serviceCategories.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final cat = index == 0 ? 'All' : AppConstants.serviceCategories[index - 1];
                    final isSelected = workerProvider.selectedCategory == cat;

                    return ChoiceChip(
                      label: Text(cat, style: const TextStyle(fontSize: 12)),
                      selected: isSelected,
                      selectedColor: AppColors.terracotta,
                      labelStyle: TextStyle(
                        color: isSelected ? AppColors.white : AppColors.charcoal,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                      onSelected: (_) => workerProvider.setJobCategory(cat),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),

              // Jobs Area: Separated Search Results vs Browse + Recommendations
              Expanded(
                child: workerProvider.isLoadingJobs
                    ? LoadingIndicator(
                        message: isSearching
                            ? 'Searching matching jobs...'
                            : 'Loading open opportunities...',
                      )
                    : isSearching
                        ? _buildSearchResultsView(context, workerProvider, jobs)
                        : _buildBrowseAndRecommendedView(context, workerProvider, workerProfile, jobs),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResultsView(
    BuildContext context,
    WorkerProvider workerProvider,
    List<JobModel> searchResults,
  ) {
    final trimmedQuery = workerProvider.searchQuery.trim();
    if (searchResults.isEmpty) {
      return EmptyStateView(
        icon: Icons.search_off_rounded,
        title: 'No jobs found for your search.',
        description: workerProvider.hasActiveFilters
            ? 'No open jobs matched "$trimmedQuery" with your active category or location filters.'
            : 'No open jobs matched "$trimmedQuery". Try different keywords or clear your search.',
        buttonLabel: workerProvider.hasActiveFilters ? 'Clear Search & Filters' : 'Clear Search',
        onButtonPressed: () {
          _searchController.clear();
          if (workerProvider.hasActiveFilters) {
            workerProvider.clearJobFilters();
          } else {
            workerProvider.clearSearchQuery();
          }
          setState(() {});
        },
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Search Results for "$trimmedQuery" (${searchResults.length})',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.deepForestTeal,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  _searchController.clear();
                  workerProvider.clearSearchQuery();
                  setState(() {});
                },
                child: const Text('Clear search'),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: searchResults.length,
            separatorBuilder: (context, index) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              return _BrowseJobCard(
                job: searchResults[index],
                isSearchResult: true,
                isProfileMatch: false,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBrowseAndRecommendedView(
    BuildContext context,
    WorkerProvider workerProvider,
    WorkerModel? workerProfile,
    List<JobModel> jobs,
  ) {
    if (jobs.isEmpty) {
      return EmptyStateView(
        icon: Icons.work_off_outlined,
        title: 'No Matching Jobs',
        description: 'No active job posts match your selected filters. Try broadening your criteria.',
        buttonLabel: 'Reset Filters',
        onButtonPressed: () {
          _searchController.clear();
          workerProvider.clearJobFilters();
          setState(() {});
        },
      );
    }

    final showRecommendedSection = !workerProvider.hasActiveFilters && workerProfile != null;
    final recommendedJobs = showRecommendedSection
        ? workerProvider.getRecommendedJobs(workerProfile)
        : <JobModel>[];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showRecommendedSection) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Recommended for Your Profile',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.charcoal,
                      ),
                    ),
                    Text(
                      'Based on your ${workerProfile.category} category & skills',
                      style: const TextStyle(fontSize: 12, color: AppColors.secondaryGrey),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (recommendedJobs.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.borderGrey),
                ),
                child: const Text(
                  'No open jobs currently match your profile category or skills. Explore all open jobs below.',
                  style: TextStyle(fontSize: 13, color: AppColors.secondaryGrey),
                ),
              )
            else ...[
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: recommendedJobs.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return _BrowseJobCard(
                    job: recommendedJobs[index],
                    isSearchResult: false,
                    isProfileMatch: true,
                  );
                },
              ),
              const SizedBox(height: 28),
            ],
          ],
          Text(
            workerProvider.hasActiveFilters
                ? 'Filtered Jobs (${jobs.length})'
                : 'All Open Jobs (${jobs.length})',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: jobs.length,
            separatorBuilder: (context, index) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              final job = jobs[index];
              final isGenuineMatch = workerProfile != null &&
                  workerProvider.doesJobMatchProfile(job, workerProfile);
              return _BrowseJobCard(
                job: job,
                isSearchResult: false,
                isProfileMatch: isGenuineMatch,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _BrowseJobCard extends StatelessWidget {
  final JobModel job;
  final bool isSearchResult;
  final bool isProfileMatch;

  const _BrowseJobCard({
    required this.job,
    this.isSearchResult = false,
    this.isProfileMatch = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      onTap: () => context.push('/worker/jobs/${job.id}', extra: job),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.tealSurface,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        job.category,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primaryTeal),
                      ),
                    ),
                    if (isSearchResult)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryTeal.withAlpha(20),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.primaryTeal.withAlpha(60)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.search_rounded, size: 12, color: AppColors.primaryTeal),
                            SizedBox(width: 4),
                            Text(
                              'Matched your search',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primaryTeal),
                            ),
                          ],
                        ),
                      ),
                    if (isProfileMatch)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.terracotta.withAlpha(20),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.terracotta.withAlpha(60)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.verified_rounded, size: 12, color: AppColors.terracotta),
                            SizedBox(width: 4),
                            Text(
                              'Matched your profile',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.terracotta),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                DateFormatter.timeAgo(job.createdAt),
                style: const TextStyle(fontSize: 12, color: AppColors.secondaryGrey),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            job.title,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.charcoal),
          ),
          const SizedBox(height: 6),
          Text(
            job.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 14, color: AppColors.secondaryGrey, height: 1.4),
          ),
          if (job.requiredSkills.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: job.requiredSkills.take(4).map((skill) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.lightGrey,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    skill,
                    style: const TextStyle(fontSize: 11, color: AppColors.charcoal, fontWeight: FontWeight.w500),
                  ),
                );
              }).toList(),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 14, color: AppColors.secondaryGrey),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '${job.location}, ${job.city}',
                  style: const TextStyle(fontSize: 12, color: AppColors.secondaryGrey),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Client: ${job.customerName}',
                style: const TextStyle(fontSize: 12, color: AppColors.secondaryGrey, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Budget', style: TextStyle(fontSize: 11, color: AppColors.secondaryGrey)),
                  Text(
                    CurrencyFormatter.format(job.budget),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primaryTeal),
                  ),
                ],
              ),
              AppButton(
                label: 'Apply Now',
                icon: Icons.send_rounded,
                onPressed: () => context.push('/worker/apply-job/${job.id}', extra: job),
                variant: AppButtonVariant.secondary,
                height: 40,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
