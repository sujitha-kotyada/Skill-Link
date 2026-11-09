import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/utils/responsive_layout.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/custom_snackbar.dart';
import '../../../models/job_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/job_provider.dart';

class PostJobScreen extends StatefulWidget {
  const PostJobScreen({super.key});

  @override
  State<PostJobScreen> createState() => _PostJobScreenState();
}

class _PostJobScreenState extends State<PostJobScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _skillInputController = TextEditingController();
  final _locationController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _dateController = TextEditingController();
  final _budgetController = TextEditingController();
  final _instructionsController = TextEditingController();

  String _selectedCategory = AppConstants.categoryElectrician;
  String _paymentType = AppConstants.rateTypeFixed;
  final List<String> _skills = [];

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _skillInputController.dispose();
    _locationController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _dateController.dispose();
    _budgetController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  void _addSkill() {
    final s = _skillInputController.text.trim();
    if (s.isNotEmpty && !_skills.contains(s)) {
      setState(() {
        _skills.add(s);
        _skillInputController.clear();
      });
    }
  }

  void _removeSkill(String s) {
    setState(() => _skills.remove(s));
  }

  Future<void> _handlePostJob() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final jobProvider = context.read<JobProvider>();
    final user = authProvider.currentUser;

    if (user == null) {
      context.go(RouteNames.login);
      return;
    }

    final now = DateTime.now();
    final job = JobModel(
      id: '',
      customerId: user.uid,
      customerName: user.fullName,
      title: _titleController.text.trim(),
      category: _selectedCategory,
      description: _descController.text.trim(),
      requiredSkills: _skills,
      location: _locationController.text.trim(),
      city: _cityController.text.trim(),
      state: _stateController.text.trim(),
      preferredDate: _dateController.text.trim().isNotEmpty ? _dateController.text.trim() : null,
      budget: double.tryParse(_budgetController.text.trim()) ?? 0.0,
      paymentType: _paymentType,
      additionalInstructions: _instructionsController.text.trim().isNotEmpty ? _instructionsController.text.trim() : null,
      status: AppConstants.jobStatusOpen,
      applicantCount: 0,
      createdAt: now,
      updatedAt: now,
    );

    final jobId = await jobProvider.createJob(job);

    if (!mounted) return;

    if (jobId != null) {
      CustomSnackBar.showSuccess(context, 'Job posted successfully! Local workers will now be able to apply.');
      context.go(RouteNames.customerJobs);
    } else {
      final msg = jobProvider.errorMessage ?? 'Failed to post job. Please try again.';
      CustomSnackBar.showError(context, msg);
    }
  }

  @override
  Widget build(BuildContext context) {
    final jobProvider = context.watch<JobProvider>();

    return Scaffold(
      backgroundColor: AppColors.warmCream,
      appBar: AppBar(
        title: const Text('Post a Service Requirement', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: MaxWidthContainer(
            maxWidth: 720,
            child: AppCard(
              padding: const EdgeInsets.all(32),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Describe What Needs To Be Done',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.charcoal,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Be as specific as possible to attract the most qualified local craftspeople.',
                      style: TextStyle(fontSize: 14, color: AppColors.secondaryGrey),
                    ),
                    const SizedBox(height: 28),

                    // Job Title
                    AppTextField(
                      controller: _titleController,
                      label: 'Job Title',
                      hint: 'e.g. Living Room False Ceiling & LED Wiring',
                      prefixIcon: Icons.title_rounded,
                      validator: (val) => Validators.validateRequired(val, 'Job Title'),
                    ),
                    const SizedBox(height: 18),

                    // Service Category
                    const Text('Service Category', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
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
                          value: _selectedCategory,
                          isExpanded: true,
                          items: AppConstants.serviceCategories.map((c) {
                            return DropdownMenuItem(
                              value: c,
                              child: Row(
                                children: [
                                  Icon(AppConstants.getCategoryIcon(c), size: 18, color: AppColors.primaryTeal),
                                  const SizedBox(width: 10),
                                  Text(c),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedCategory = val);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Budget & Payment Type Row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: AppTextField(
                            controller: _budgetController,
                            label: 'Estimated Budget (₹)',
                            hint: 'e.g. 2000',
                            prefixIcon: Icons.currency_rupee_rounded,
                            keyboardType: TextInputType.number,
                            validator: (val) => Validators.validateNumber(val, 'Budget'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Payment Type', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
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
                                    value: _paymentType,
                                    isExpanded: true,
                                    items: const [
                                      DropdownMenuItem(value: AppConstants.rateTypeFixed, child: Text('Fixed Project Budget')),
                                      DropdownMenuItem(value: AppConstants.rateTypeHourly, child: Text('Hourly Rate Estimate')),
                                    ],
                                    onChanged: (val) {
                                      if (val != null) setState(() => _paymentType = val);
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Location fields
                    Row(
                      children: [
                        Expanded(
                          child: AppTextField(
                            controller: _cityController,
                            label: 'City',
                            hint: 'e.g. Bengaluru',
                            prefixIcon: Icons.location_city_rounded,
                            validator: (val) => Validators.validateRequired(val, 'City'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: AppTextField(
                            controller: _stateController,
                            label: 'State',
                            hint: 'e.g. Karnataka',
                            prefixIcon: Icons.map_outlined,
                            validator: (val) => Validators.validateRequired(val, 'State'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    AppTextField(
                      controller: _locationController,
                      label: 'Locality / Area',
                      hint: 'e.g. HSR Layout Sector 2',
                      prefixIcon: Icons.pin_drop_outlined,
                      validator: (val) => Validators.validateRequired(val, 'Locality'),
                    ),
                    const SizedBox(height: 18),

                    // Preferred Date / Timeline
                    AppTextField(
                      controller: _dateController,
                      label: 'Preferred Date or Timeline (Optional)',
                      hint: 'e.g. This Saturday, or Within 3 days',
                      prefixIcon: Icons.calendar_today_outlined,
                    ),
                    const SizedBox(height: 18),

                    // Skills Tags
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Specific Skills Needed', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _skillInputController,
                                decoration: const InputDecoration(
                                  hintText: 'e.g. Concealed Wiring, Heavy Drilling',
                                ),
                                onSubmitted: (_) => _addSkill(),
                              ),
                            ),
                            const SizedBox(width: 10),
                            IconButton.filled(
                              icon: const Icon(Icons.add),
                              style: IconButton.styleFrom(backgroundColor: AppColors.primaryTeal),
                              onPressed: _addSkill,
                            ),
                          ],
                        ),
                        if (_skills.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _skills.map((s) {
                              return Chip(
                                label: Text(s, style: const TextStyle(fontSize: 12)),
                                deleteIcon: const Icon(Icons.close, size: 16),
                                onDeleted: () => _removeSkill(s),
                                backgroundColor: AppColors.tealSurface,
                                side: BorderSide.none,
                              );
                            }).toList(),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Description
                    AppTextField(
                      controller: _descController,
                      label: 'Detailed Job Description',
                      hint: 'Describe the work in detail, including dimensions, materials provided or needed...',
                      prefixIcon: Icons.description_outlined,
                      maxLines: 4,
                      validator: (val) => Validators.validateRequired(val, 'Description'),
                    ),
                    const SizedBox(height: 18),

                    // Instructions
                    AppTextField(
                      controller: _instructionsController,
                      label: 'Additional Instructions (Optional)',
                      hint: 'e.g. Please bring own ladder, parking available in basement',
                      prefixIcon: Icons.info_outline,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 32),

                    // Submit
                    AppButton(
                      label: 'Publish Job Post',
                      icon: Icons.send_rounded,
                      isLoading: jobProvider.isLoading,
                      onPressed: _handlePostJob,
                      isFullWidth: true,
                      variant: AppButtonVariant.primary,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
