import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/responsive_layout.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/custom_snackbar.dart';
import '../../../models/application_model.dart';
import '../../../models/job_model.dart';
import '../../../providers/application_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/job_provider.dart';

class ApplyJobScreen extends StatefulWidget {
  final String jobId;
  final JobModel? initialJob;

  const ApplyJobScreen({
    super.key,
    required this.jobId,
    this.initialJob,
  });

  @override
  State<ApplyJobScreen> createState() => _ApplyJobScreenState();
}

class _ApplyJobScreenState extends State<ApplyJobScreen> {
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();
  final _proposedRateController = TextEditingController();

  JobModel? _job;
  bool _isLoadingJob = false;
  bool _isSubmitting = false;
  bool _alreadyApplied = false;
  String _proposedRateType = AppConstants.rateTypeFixed;

  @override
  void initState() {
    super.initState();
    _job = widget.initialJob;
    if (_job == null) {
      _loadJob();
    } else {
      _proposedRateController.text = _job!.budget.toStringAsFixed(0);
      _proposedRateType = _job!.paymentType;
      _checkAlreadyApplied();
    }
  }

  Future<void> _checkAlreadyApplied() async {
    final user = context.read<AuthProvider>().currentUser;
    if (user != null && _job != null) {
      final applied = await context.read<ApplicationProvider>().checkAlreadyApplied(
        jobId: _job!.id,
        workerId: user.uid,
      );
      if (mounted) setState(() => _alreadyApplied = applied);
    }
  }

  Future<void> _loadJob() async {
    setState(() => _isLoadingJob = true);
    final j = await context.read<JobProvider>().getJobById(widget.jobId);
    if (mounted) {
      setState(() {
        _job = j;
        _isLoadingJob = false;
        if (j != null) {
          _proposedRateController.text = j.budget.toStringAsFixed(0);
          _proposedRateType = j.paymentType;
        }
      });
      if (j != null) {
        _checkAlreadyApplied();
      }
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _proposedRateController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_isSubmitting) return;
    if (!_formKey.currentState!.validate()) return;
    if (_job == null) return;

    final authProvider = context.read<AuthProvider>();
    final appProvider = context.read<ApplicationProvider>();
    final user = authProvider.currentUser;
    final worker = authProvider.workerProfile;

    if (user == null) {
      context.go(RouteNames.login);
      return;
    }

    if (user.uid == _job!.customerId) {
      CustomSnackBar.showError(context, 'You cannot apply to a job you posted.');
      return;
    }

    if (_alreadyApplied) {
      CustomSnackBar.showError(context, 'You have already applied for this job.');
      return;
    }

    setState(() => _isSubmitting = true);

    final now = DateTime.now();
    final application = ApplicationModel(
      id: '',
      jobId: _job!.id,
      jobTitle: _job!.title,
      customerId: _job!.customerId,
      workerId: user.uid,
      workerName: user.fullName,
      workerCategory: worker?.category ?? _job!.category,
      workerPhotoUrl: user.photoUrl,
      workerAverageRating: worker?.averageRating ?? 0.0,
      workerHeadline: worker?.headline ?? '',
      workerSkills: worker?.skills ?? [],
      workerExperienceYears: worker?.experienceYears ?? 0,
      workerLocation: worker?.locationString ?? (worker?.city ?? ''),
      message: _messageController.text.trim(),
      proposedRate: double.tryParse(_proposedRateController.text.trim()) ?? _job!.budget,
      proposedRateType: _proposedRateType,
      status: AppConstants.appStatusApplied,
      createdAt: now,
      updatedAt: now,
    );

    final success = await appProvider.applyForJob(application);

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (success) {
      CustomSnackBar.showSuccess(context, 'Proposal submitted successfully! The customer has been notified.');
      context.go(RouteNames.workerApplications);
    } else {
      final msg = appProvider.errorMessage ?? 'Failed to submit proposal.';
      CustomSnackBar.showError(context, msg);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<ApplicationProvider>();

    if (_isLoadingJob) {
      return const Scaffold(
        backgroundColor: AppColors.warmCream,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_job == null) {
      return Scaffold(
        backgroundColor: AppColors.warmCream,
        appBar: AppBar(),
        body: const Center(child: Text('Job not found.')),
      );
    }

    final job = _job!;

    return Scaffold(
      backgroundColor: AppColors.warmCream,
      appBar: AppBar(
        title: const Text('Submit Proposal', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: MaxWidthContainer(
            maxWidth: 680,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Job Summary Card
                AppCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            job.category,
                            style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primaryTeal, fontSize: 13),
                          ),
                          Text(
                            'Budget: ${CurrencyFormatter.format(job.budget)}',
                            style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.charcoal, fontSize: 15),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        job.title,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.charcoal),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Location: ${job.location}, ${job.city}',
                        style: const TextStyle(fontSize: 13, color: AppColors.secondaryGrey),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Application Form Card
                AppCard(
                  padding: const EdgeInsets.all(28),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Your Proposal Details',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.charcoal),
                        ),
                        const SizedBox(height: 20),

                        // Proposed Rate
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: AppTextField(
                                controller: _proposedRateController,
                                label: 'Your Proposed Rate (₹)',
                                hint: 'e.g. 1800',
                                prefixIcon: Icons.currency_rupee_rounded,
                                keyboardType: TextInputType.number,
                                validator: (val) => Validators.validateNumber(val, 'Proposed Rate'),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Rate Type', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    decoration: BoxDecoration(
                                      color: AppColors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: AppColors.borderGrey),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value: _proposedRateType,
                                        isExpanded: true,
                                        items: const [
                                          DropdownMenuItem(value: AppConstants.rateTypeFixed, child: Text('Total Project')),
                                          DropdownMenuItem(value: AppConstants.rateTypeHourly, child: Text('Per Hour')),
                                        ],
                                        onChanged: (val) {
                                          if (val != null) setState(() => _proposedRateType = val);
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Message / Cover Note
                        AppTextField(
                          controller: _messageController,
                          label: 'Introduction & Proposal Message',
                          hint: 'Explain your experience with this type of work, tools you will bring, and your availability...',
                          prefixIcon: Icons.message_outlined,
                          maxLines: 5,
                          validator: (val) => Validators.validateRequired(val, 'Proposal message'),
                        ),
                        if (_alreadyApplied) ...[
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.tealSurface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.primaryTeal),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.check_circle_rounded, color: AppColors.primaryTeal, size: 24),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Text(
                                    'You have already submitted a proposal for this job.',
                                    style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.deepForestTeal),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          AppButton(
                            label: 'View My Applications',
                            icon: Icons.list_alt_rounded,
                            onPressed: () => context.go(RouteNames.workerApplications),
                            isFullWidth: true,
                            variant: AppButtonVariant.primary,
                          ),
                        ] else ...[
                          const SizedBox(height: 28),
                          AppButton(
                            label: 'Submit Application',
                            icon: Icons.send_rounded,
                            isLoading: _isSubmitting || appProvider.isSubmitting,
                            onPressed: (_isSubmitting || appProvider.isSubmitting) ? null : _handleSubmit,
                            isFullWidth: true,
                            variant: AppButtonVariant.secondary,
                          ),
                        ],
                      ],
                    ),
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

