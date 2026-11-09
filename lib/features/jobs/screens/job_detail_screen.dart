import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/responsive_layout.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../models/job_model.dart';
import '../../../providers/application_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/job_provider.dart';

class JobDetailScreen extends StatefulWidget {
  final String jobId;
  final JobModel? initialJob;

  const JobDetailScreen({
    super.key,
    required this.jobId,
    this.initialJob,
  });

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  JobModel? _job;
  bool _isLoading = false;
  bool _alreadyApplied = false;

  @override
  void initState() {
    super.initState();
    _job = widget.initialJob;
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    final jobProvider = context.read<JobProvider>();
    final appProvider = context.read<ApplicationProvider>();
    final authProvider = context.read<AuthProvider>();

    if (_job == null) {
      setState(() => _isLoading = true);
      final fetched = await jobProvider.getJobById(widget.jobId);
      if (mounted) setState(() => _job = fetched);
    }

    final user = authProvider.currentUser;
    if (user != null && _job != null && user.uid != _job!.customerId) {
      final hasApplied = await appProvider.checkAlreadyApplied(
        jobId: _job!.id,
        workerId: user.uid,
      );
      if (mounted) {
        setState(() {
          _alreadyApplied = hasApplied;
          _isLoading = false;
        });
      }
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final jobProvider = context.watch<JobProvider>();
    final user = authProvider.currentUser;

    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.warmCream,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_job == null) {
      return Scaffold(
        backgroundColor: AppColors.warmCream,
        appBar: AppBar(),
        body: const Center(child: Text('Job post not found.')),
      );
    }

    final job = _job!;
    final isCustomerOwner = user?.uid == job.customerId;

    return Scaffold(
      backgroundColor: AppColors.warmCream,
      appBar: AppBar(
        title: const Text('Job Details', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: MaxWidthContainer(
            maxWidth: 800,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Header Card
                AppCard(
                  padding: const EdgeInsets.all(28),
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
                                style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.secondaryGrey),
                              ),
                            ],
                          ),
                          Text(
                            DateFormatter.timeAgo(job.createdAt),
                            style: const TextStyle(fontSize: 12, color: AppColors.secondaryGrey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        job.title,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.charcoal),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.person_outline_rounded, size: 16, color: AppColors.secondaryGrey),
                          const SizedBox(width: 4),
                          Text('Posted by ${job.customerName}', style: const TextStyle(fontSize: 13, color: AppColors.secondaryGrey)),
                          const SizedBox(width: 16),
                          const Icon(Icons.location_on_outlined, size: 16, color: AppColors.secondaryGrey),
                          const SizedBox(width: 4),
                          Text('${job.location}, ${job.city}', style: const TextStyle(fontSize: 13, color: AppColors.secondaryGrey)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Budget & Schedule Row
                Row(
                  children: [
                    Expanded(
                      child: AppCard(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Estimated Budget', style: TextStyle(fontSize: 12, color: AppColors.secondaryGrey)),
                            const SizedBox(height: 4),
                            Text(
                              CurrencyFormatter.format(job.budget),
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.primaryTeal),
                            ),
                            Text('Payment type: ${job.paymentType}', style: const TextStyle(fontSize: 11, color: AppColors.secondaryGrey)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: AppCard(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Preferred Timeline', style: TextStyle(fontSize: 12, color: AppColors.secondaryGrey)),
                            const SizedBox(height: 4),
                            Text(
                              job.preferredDate ?? 'Flexible schedule',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.charcoal),
                            ),
                            const SizedBox(height: 4),
                            Text('${job.applicantCount} proposals submitted', style: const TextStyle(fontSize: 11, color: AppColors.secondaryGrey)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Description Card
                AppCard(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Project Description',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.charcoal),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        job.description,
                        style: const TextStyle(fontSize: 15, color: AppColors.charcoal, height: 1.6),
                      ),
                      if (job.requiredSkills.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        const Text(
                          'Required Skills',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.charcoal),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: job.requiredSkills.map((s) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.tealSurface,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(s, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primaryTeal)),
                            );
                          }).toList(),
                        ),
                      ],
                      if (job.additionalInstructions != null && job.additionalInstructions!.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        const Text(
                          'Special Instructions',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.charcoal),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          job.additionalInstructions!,
                          style: const TextStyle(fontSize: 14, color: AppColors.secondaryGrey, height: 1.4),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // Action Area Based on User Role
                if (isCustomerOwner) ...[
                  AppButton(
                    label: 'Review Applications (${job.applicantCount})',
                    icon: Icons.people_outline_rounded,
                    onPressed: () => context.push('/customer/jobs/${job.id}/applications', extra: job),
                    isFullWidth: true,
                    variant: AppButtonVariant.primary,
                  ),
                  const SizedBox(height: 12),
                  if (job.isOpen)
                    Row(
                      children: [
                        Expanded(
                          child: AppButton(
                            label: 'Mark Completed',
                            icon: Icons.check_circle_outline,
                            onPressed: () async {
                              final nav = Navigator.of(context);
                              await jobProvider.completeJob(job.id);
                              if (mounted) nav.pop();
                            },
                            variant: AppButtonVariant.outlined,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AppButton(
                            label: 'Cancel Job',
                            icon: Icons.cancel_outlined,
                            onPressed: () async {
                              final nav = Navigator.of(context);
                              await jobProvider.cancelJob(job.id);
                              if (mounted) nav.pop();
                            },
                            variant: AppButtonVariant.danger,
                          ),
                        ),
                      ],
                    ),
                ] else ...[
                  // Worker View
                  if (_alreadyApplied)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.successGreen),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.check_circle_rounded, color: AppColors.successGreen),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'You have already submitted a proposal for this job. Track status in My Applications.',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.charcoal),
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (job.isOpen)
                    AppButton(
                      label: 'Apply for This Job',
                      icon: Icons.send_rounded,
                      onPressed: () => context.push('/worker/apply-job/${job.id}', extra: job),
                      isFullWidth: true,
                      variant: AppButtonVariant.secondary,
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.lightGrey,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          'This job is currently ${job.status.toUpperCase()} and no longer accepting proposals.',
                          style: const TextStyle(color: AppColors.secondaryGrey, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
