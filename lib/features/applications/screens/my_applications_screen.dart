import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/responsive_layout.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../models/application_model.dart';
import '../../../providers/application_provider.dart';
import '../../../providers/auth_provider.dart';

class MyApplicationsScreen extends StatefulWidget {
  const MyApplicationsScreen({super.key});

  @override
  State<MyApplicationsScreen> createState() => _MyApplicationsScreenState();
}

class _MyApplicationsScreenState extends State<MyApplicationsScreen> {
  String _selectedStatus = 'all';

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final appProvider = context.watch<ApplicationProvider>();
    final user = authProvider.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: Text('Please sign in to view your applications.')));
    }

    return Scaffold(
      backgroundColor: AppColors.warmCream,
      appBar: AppBar(
        title: const Text('My Applications', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: SafeArea(
        child: MaxWidthContainer(
          child: Column(
            children: [
              const SizedBox(height: 16),
              // Status Filter Tabs
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildFilterChip('all', 'All Applications'),
                    const SizedBox(width: 8),
                    _buildFilterChip(AppConstants.appStatusApplied, 'Applied'),
                    const SizedBox(width: 8),
                    _buildFilterChip(AppConstants.appStatusUnderReview, 'Under Review'),
                    const SizedBox(width: 8),
                    _buildFilterChip(AppConstants.appStatusAccepted, 'Accepted'),
                    const SizedBox(width: 8),
                    _buildFilterChip(AppConstants.appStatusRejected, 'Rejected'),
                    const SizedBox(width: 8),
                    _buildFilterChip(AppConstants.appStatusWithdrawn, 'Withdrawn'),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              Expanded(
                child: StreamBuilder<List<ApplicationModel>>(
                  stream: appProvider.streamWorkerApplications(user.uid),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final allApps = snapshot.data ?? [];
                    final filteredApps = _selectedStatus == 'all'
                        ? allApps
                        : allApps.where((a) => a.status == _selectedStatus).toList();

                    if (filteredApps.isEmpty) {
                      return EmptyStateView(
                        icon: Icons.assignment_outlined,
                        title: 'No Applications',
                        description: _selectedStatus == 'all'
                            ? 'You have not submitted any job proposals yet.'
                            : 'No applications found with status "$_selectedStatus".',
                        buttonLabel: 'Browse Available Jobs',
                        onButtonPressed: () => context.go(RouteNames.workerBrowseJobs),
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: filteredApps.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        final app = filteredApps[index];
                        return _WorkerApplicationCard(application: app);
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

  Widget _buildFilterChip(String value, String label) {
    final isSelected = _selectedStatus == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.terracotta,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.white : AppColors.charcoal,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        fontSize: 12,
      ),
      onSelected: (_) => setState(() => _selectedStatus = value),
    );
  }
}

class _WorkerApplicationCard extends StatelessWidget {
  final ApplicationModel application;

  const _WorkerApplicationCard({required this.application});

  @override
  Widget build(BuildContext context) {
    final appProvider = context.read<ApplicationProvider>();

    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              StatusBadge(status: application.status),
              Text(
                DateFormatter.formatDate(application.createdAt),
                style: const TextStyle(fontSize: 12, color: AppColors.secondaryGrey),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            application.jobTitle,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.charcoal),
          ),
          const SizedBox(height: 6),
          Text(
            'Proposed: ${CurrencyFormatter.format(application.proposedRate)} (${application.proposedRateType})',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primaryTeal),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.warmCream,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.borderGrey),
            ),
            child: Text(
              application.message,
              style: const TextStyle(fontSize: 13, color: AppColors.charcoal, height: 1.4),
            ),
          ),
          const SizedBox(height: 14),

          // Actions
          Row(
            children: [
              TextButton.icon(
                icon: const Icon(Icons.open_in_new_rounded, size: 16),
                label: const Text('View Job Details'),
                onPressed: () => context.push('/worker/jobs/${application.jobId}'),
              ),
              const Spacer(),
              if (application.isApplied)
                TextButton(
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Withdraw Proposal?'),
                        content: const Text('Are you sure you want to withdraw this application?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Keep')),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.errorRed),
                            child: const Text('Withdraw'),
                          ),
                        ],
                      ),
                    );
                    if (confirmed == true) {
                      await appProvider.withdrawApplication(application);
                    }
                  },
                  child: const Text('Withdraw', style: TextStyle(color: AppColors.errorRed)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
