import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/responsive_layout.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../providers/customer_provider.dart';
import '../widgets/worker_card.dart';
import '../widgets/worker_filter_sheet.dart';

class FindWorkersScreen extends StatefulWidget {
  const FindWorkersScreen({super.key});

  @override
  State<FindWorkersScreen> createState() => _FindWorkersScreenState();
}

class _FindWorkersScreenState extends State<FindWorkersScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<CustomerProvider>();
      _searchController.text = p.searchQuery;
      p.fetchWorkers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openFilterSheet() {
    final p = context.read<CustomerProvider>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => WorkerFilterSheet(
        currentCategory: p.selectedCategory,
        currentCity: p.selectedCity,
        currentMaxRate: p.maxRate,
        currentMinRating: p.minRating,
        currentSortBy: p.sortBy,
        onApply: ({
          required String category,
          required String city,
          required double? maxRate,
          required double? minRating,
          required String sortBy,
        }) {
          p.setFilters(
            category: category,
            city: city,
            maxRate: maxRate,
            minRating: minRating,
            sortBy: sortBy,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CustomerProvider>();

    return Scaffold(
      backgroundColor: AppColors.warmCream,
      appBar: AppBar(
        title: const Text(
          'Find Skilled Workers',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded, color: AppColors.primaryTeal),
            tooltip: 'Filter Workers',
            onPressed: _openFilterSheet,
          ),
        ],
      ),
      body: SafeArea(
        child: MaxWidthContainer(
          child: Column(
            children: [
              const SizedBox(height: 16),
              // Search input & Filter row
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
                            hintText: 'Search by skill, profession or name...',
                            prefixIcon: const Icon(Icons.search_rounded, size: 20),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear, size: 18),
                                    onPressed: () {
                                      _searchController.clear();
                                      provider.setSearchQuery('');
                                    },
                                  )
                                : null,
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                          onSubmitted: (val) => provider.setSearchQuery(val),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    InkWell(
                      onTap: _openFilterSheet,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.tealSurface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.primaryTeal.withAlpha((0.3 * 255).round())),
                        ),
                        child: const Icon(Icons.tune_rounded, color: AppColors.primaryTeal, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Category Filter Horizontal Scroll
              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: 1 + AppConstants.serviceCategories.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final cat = index == 0 ? 'All' : AppConstants.serviceCategories[index - 1];
                    final isSelected = provider.selectedCategory == cat;

                    return ChoiceChip(
                      label: Text(cat, style: const TextStyle(fontSize: 12)),
                      selected: isSelected,
                      selectedColor: AppColors.primaryTeal,
                      labelStyle: TextStyle(
                        color: isSelected ? AppColors.white : AppColors.charcoal,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                      onSelected: (_) => provider.setCategory(cat),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),

              // Active Filter Summary & Result Count
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${provider.workers.length} professionals found',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.secondaryGrey,
                      ),
                    ),
                    if (provider.selectedCategory != 'All' ||
                        provider.selectedCity.isNotEmpty ||
                        provider.maxRate != null ||
                        provider.searchQuery.isNotEmpty)
                      TextButton(
                        onPressed: () {
                          _searchController.clear();
                          provider.clearFilters();
                        },
                        style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                        child: const Text('Clear Filters', style: TextStyle(fontSize: 12)),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Main Results Content
              Expanded(
                child: provider.isLoadingWorkers
                    ? const LoadingIndicator(message: 'Searching available local workers...')
                    : provider.workers.isEmpty
                        ? EmptyStateView(
                            icon: Icons.person_off_rounded,
                            title: 'No Workers Found',
                            description: 'No professionals match your current filters. Try resetting filters or expanding your search criteria.',
                            buttonLabel: 'Reset Filters',
                            onButtonPressed: () {
                              _searchController.clear();
                              provider.clearFilters();
                            },
                          )
                        : LayoutBuilder(
                            builder: (context, constraints) {
                              final crossAxisCount = constraints.maxWidth > 900 ? 3 : (constraints.maxWidth > 600 ? 2 : 1);
                              return GridView.builder(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                  childAspectRatio: crossAxisCount == 1 ? 1.5 : 1.35,
                                ),
                                itemCount: provider.workers.length,
                                itemBuilder: (context, index) {
                                  return WorkerCard(worker: provider.workers[index]);
                                },
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
