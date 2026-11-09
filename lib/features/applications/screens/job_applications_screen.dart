import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/responsive_layout.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/custom_snackbar.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/rating_stars.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../models/application_model.dart';
import '../../../models/job_model.dart';
import '../../../providers/application_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/job_provider.dart';

class JobApplicationsScreen extends StatefulWidget {
  final String jobId;
  final JobModel? initialJob;

  const JobApplicationsScreen({
    super.key,
    required this.jobId,
    this.initialJob,
  });

  @override
  State<JobApplicationsScreen> createState() => _JobApplicationsScreenState();
}

class _JobApplicationsScreenState extends State<JobApplicationsScreen> {
  JobModel? _job;

  @override
  void initState() {
    super.initState();
    _job = widget.initialJob;
    if (_job == null) {
      _loadJob();
    }
  }

  Future<void> _loadJob() async {
    final j = await context.read<JobProvider>().getJobById(widget.jobId);
    if (mounted) setState(() => _job = j);
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<ApplicationProvider>();
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    if (_job != null && user != null && _job!.customerId != user.uid) {
      return Scaffold(
        backgroundColor: AppColors.warmCream,
        appBar: AppBar(),
        body: const Center(
          child: Text('Unauthorized: You can only view proposals for your own jobs.'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.warmCream,
      appBar: AppBar(
        title: Text(
          _job != null ? 'Proposals: ${_job!.title}' : 'Job Proposals',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: MaxWidthContainer(
          child: StreamBuilder<List<ApplicationModel>>(
            stream: appProvider.streamApplicationsForJob(
              widget.jobId,
              customerId: user?.uid,
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.errorRed),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading proposals: ${snapshot.error}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppColors.errorRed, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final applications = snapshot.data ?? [];

              if (applications.isEmpty) {
                return EmptyStateView(
                  icon: Icons.people_outline_rounded,
                  title: 'No Applications Yet',
                  description: 'Local workers will see your job and submit their proposals soon. Check back shortly!',
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 24),
                itemCount: applications.length,
                separatorBuilder: (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final app = applications[index];
                  return _ApplicationDetailCard(
                    application: app,
                    job: _job,
                    isCustomerOwner: user?.uid == _job?.customerId,
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ApplicationDetailCard extends StatelessWidget {
  final ApplicationModel application;
  final JobModel? job;
  final bool isCustomerOwner;

  const _ApplicationDetailCard({
    required this.application,
    this.job,
    this.isCustomerOwner = true,
  });

  @override
  Widget build(BuildContext context) {
    final appProvider = context.read<ApplicationProvider>();

    return AppCard(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppAvatar(
                name: application.workerName,
                imageUrl: application.workerPhotoUrl,
                radius: 26,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      application.workerName,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.charcoal),
                    ),
                    if (application.workerHeadline.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        application.workerHeadline,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primaryTeal),
                      ),
                    ],
                    Text(
                      application.workerCategory,
                      style: const TextStyle(fontSize: 13, color: AppColors.secondaryGrey),
                    ),
                    const SizedBox(height: 4),
                    RatingStars(
                      rating: application.workerAverageRating,
                      showCount: false,
                      starSize: 14,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  StatusBadge(status: application.status),
                  const SizedBox(height: 6),
                  Text(
                    CurrencyFormatter.format(application.proposedRate),
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.primaryTeal),
                  ),
                  Text(
                    application.proposedRateType,
                    style: const TextStyle(fontSize: 11, color: AppColors.secondaryGrey),
                  ),
                ],
              ),
            ],
          ),

          // Worker Details: Location & Experience
          if (application.workerLocation.isNotEmpty || application.workerExperienceYears > 0) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 6,
              children: [
                if (application.workerLocation.isNotEmpty)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.location_on_outlined, size: 14, color: AppColors.secondaryGrey),
                      const SizedBox(width: 4),
                      Text(
                        application.workerLocation,
                        style: const TextStyle(fontSize: 12, color: AppColors.secondaryGrey),
                      ),
                    ],
                  ),
                if (application.workerExperienceYears > 0)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.work_history_outlined, size: 14, color: AppColors.secondaryGrey),
                      const SizedBox(width: 4),
                      Text(
                        '${application.workerExperienceYears} years exp',
                        style: const TextStyle(fontSize: 12, color: AppColors.secondaryGrey),
                      ),
                    ],
                  ),
              ],
            ),
          ],

          // Worker Skills
          if (application.workerSkills.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: application.workerSkills.map((skill) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.tealSurface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    skill,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primaryTeal),
                  ),
                );
              }).toList(),
            ),
          ],

          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.warmCream,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderGrey),
            ),
            child: Text(
              application.message,
              style: const TextStyle(fontSize: 14, color: AppColors.charcoal, height: 1.5),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Submitted ${DateFormatter.formatDateTime(application.createdAt)}',
            style: const TextStyle(fontSize: 12, color: AppColors.secondaryGrey),
          ),
          const Divider(height: 24),

          // Actions
          Row(
            children: [
              OutlinedButton.icon(
                icon: const Icon(Icons.person_outline, size: 16),
                label: const Text('View Worker Profile', style: TextStyle(fontSize: 13)),
                onPressed: () => context.push('/customer/workers/${application.workerId}'),
              ),
              const Spacer(),
              if (isCustomerOwner && (application.isApplied || application.isUnderReview)) ...[
                TextButton(
                  onPressed: () async {
                    final ok = await appProvider.rejectApplication(application);
                    if (context.mounted && ok) {
                      CustomSnackBar.showInfo(context, 'Proposal rejected.');
                    }
                  },
                  child: const Text('Reject', style: TextStyle(color: AppColors.errorRed)),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () async {
                    final ok = await appProvider.acceptApplication(application);
                    if (context.mounted && ok) {
                      CustomSnackBar.showSuccess(context, 'Accepted proposal! Worker has been notified.');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.successGreen,
                    foregroundColor: AppColors.white,
                  ),
                  child: const Text('Accept Worker'),
                ),
              ] else if (isCustomerOwner && application.isAccepted) ...[
                // If accepted and customer wants to leave a review
                ElevatedButton.icon(
                  icon: const Icon(Icons.star_outline_rounded, size: 16),
                  label: const Text('Write Review'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.mutedSaffron),
                  onPressed: () => context.push(
                    '/reviews/write?jobId=${application.jobId}&workerId=${application.workerId}&jobTitle=${Uri.encodeComponent(application.jobTitle)}',
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
