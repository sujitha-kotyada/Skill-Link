import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/responsive_layout.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../models/application_model.dart';
import '../../../models/job_model.dart';
import '../../../providers/application_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/job_provider.dart';

class CustomerJobsScreen extends StatefulWidget {
  const CustomerJobsScreen({super.key});

  @override
  State<CustomerJobsScreen> createState() => _CustomerJobsScreenState();
}

class _CustomerJobsScreenState extends State<CustomerJobsScreen> {
  String _selectedStatusFilter = 'all';

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final jobProvider = context.watch<JobProvider>();
    final appProvider = context.watch<ApplicationProvider>();
    final user = authProvider.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: Text('Please sign in to view your jobs.')));
    }

    return Scaffold(
      backgroundColor: AppColors.warmCream,
      appBar: AppBar(
        title: const Text('My Posted Jobs', style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.primaryTeal),
            tooltip: 'Post a New Job',
            onPressed: () => context.push(RouteNames.customerPostJob),
          ),
        ],
      ),
      body: SafeArea(
        child: MaxWidthContainer(
          child: Column(
            children: [
              const SizedBox(height: 16),
              // Status Filters
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildFilterChip('all', 'All Jobs'),
                    const SizedBox(width: 8),
                    _buildFilterChip(AppConstants.jobStatusOpen, 'Open'),
                    const SizedBox(width: 8),
                    _buildFilterChip(AppConstants.jobStatusInProgress, 'In Progress'),
                    const SizedBox(width: 8),
                    _buildFilterChip(AppConstants.jobStatusCompleted, 'Completed'),
                    const SizedBox(width: 8),
                    _buildFilterChip(AppConstants.jobStatusCancelled, 'Cancelled'),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Jobs Stream
              Expanded(
                child: StreamBuilder<List<JobModel>>(
                  stream: jobProvider.streamCustomerJobs(user.uid),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final allJobs = snapshot.data ?? [];
                    final filteredJobs = _selectedStatusFilter == 'all'
                        ? allJobs
                        : allJobs.where((j) => j.status == _selectedStatusFilter).toList();

                    if (filteredJobs.isEmpty) {
                      return EmptyStateView(
                        icon: Icons.work_outline_rounded,
                        title: 'No Jobs Found',
                        description: _selectedStatusFilter == 'all'
                            ? 'You have not posted any service requirements yet.'
                            : 'No jobs found matching the "$_selectedStatusFilter" filter.',
                        buttonLabel: 'Post a Job Now',
                        onButtonPressed: () => context.push(RouteNames.customerPostJob),
                      );
                    }

                    return StreamBuilder<List<ApplicationModel>>(
                      stream: appProvider.streamCustomerApplications(user.uid),
                      builder: (context, appSnapshot) {
                        final allApps = appSnapshot.data ?? [];
                        return ListView.separated(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: filteredJobs.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 14),
                          itemBuilder: (context, index) {
                            final job = filteredJobs[index];
                            final count = ApplicationProvider.countActiveProposals(allApps, jobId: job.id);
                            return _CustomerJobDetailedCard(job: job, proposalCount: count);
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primaryTeal,
        foregroundColor: AppColors.white,
        icon: const Icon(Icons.add),
        label: const Text('Post New Job', style: TextStyle(fontWeight: FontWeight.w700)),
        onPressed: () => context.push(RouteNames.customerPostJob),
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = _selectedStatusFilter == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.primaryTeal,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.white : AppColors.charcoal,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        fontSize: 12,
      ),
      onSelected: (_) => setState(() => _selectedStatusFilter = value),
    );
  }
}

class _CustomerJobDetailedCard extends StatelessWidget {
  final JobModel job;
  final int proposalCount;

  const _CustomerJobDetailedCard({
    required this.job,
    this.proposalCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final jobProvider = context.read<JobProvider>();

    return AppCard(
      padding: const EdgeInsets.all(20),
      onTap: () => context.push('/customer/jobs/${job.id}', extra: job),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  StatusBadge(status: job.status),
                  const SizedBox(width: 8),
                  Text(
                    job.category,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.secondaryGrey),
                  ),
                ],
              ),
              Text(
                DateFormatter.formatDate(job.createdAt),
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
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 15, color: AppColors.secondaryGrey),
              const SizedBox(width: 4),
              Text('${job.location}, ${job.city}', style: const TextStyle(fontSize: 13, color: AppColors.secondaryGrey)),
              const Spacer(),
              Text(
                CurrencyFormatter.format(job.budget),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.primaryTeal),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            children: [
              // Applications Counter Button
              AppButton(
                label: ApplicationProvider.formatApplicationCount(proposalCount),
                icon: Icons.people_outline_rounded,
                onPressed: () => context.push('/customer/jobs/${job.id}/applications', extra: job),
                variant: AppButtonVariant.primary,
                height: 38,
              ),
              const Spacer(),
              if (job.isOpen) ...[
                TextButton(
                  onPressed: () => jobProvider.completeJob(job.id),
                  child: const Text('Mark Complete', style: TextStyle(color: AppColors.successGreen)),
                ),
                TextButton(
                  onPressed: () => jobProvider.cancelJob(job.id),
                  child: const Text('Cancel Job', style: TextStyle(color: AppColors.errorRed)),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
