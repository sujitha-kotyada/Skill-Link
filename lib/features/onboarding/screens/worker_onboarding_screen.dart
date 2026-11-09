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
import '../../../models/worker_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/worker_provider.dart';

class WorkerOnboardingScreen extends StatefulWidget {
  const WorkerOnboardingScreen({super.key});

  @override
  State<WorkerOnboardingScreen> createState() => _WorkerOnboardingScreenState();
}

class _WorkerOnboardingScreenState extends State<WorkerOnboardingScreen> {
  final _formKey = GlobalKey<FormState>();

  final _headlineController = TextEditingController();
  final _descController = TextEditingController();
  final _skillInputController = TextEditingController();
  final _experienceController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _localityController = TextEditingController();
  final _rateController = TextEditingController();
  final _phoneController = TextEditingController();

  String _selectedCategory = AppConstants.categoryElectrician;
  String _rateType = AppConstants.rateTypeHourly;
  String _availability = AppConstants.availabilityOptions.first;
  final List<String> _skills = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.workerProfile != null) {
        final p = auth.workerProfile!;
        _headlineController.text = p.headline;
        _descController.text = p.description;
        _experienceController.text = p.experienceYears.toString();
        _cityController.text = p.city;
        _stateController.text = p.state;
        _localityController.text = p.locality;
        _rateController.text = p.rate.toStringAsFixed(0);
        _phoneController.text = p.contactPhone ?? '';
        setState(() {
          _selectedCategory = p.category;
          _rateType = p.rateType;
          _availability = p.availability;
          _skills.addAll(p.skills);
        });
      }
    });
  }

  @override
  void dispose() {
    _headlineController.dispose();
    _descController.dispose();
    _skillInputController.dispose();
    _experienceController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _localityController.dispose();
    _rateController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _addSkill() {
    final text = _skillInputController.text.trim();
    if (text.isNotEmpty && !_skills.contains(text)) {
      setState(() {
        _skills.add(text);
        _skillInputController.clear();
      });
    }
  }

  void _removeSkill(String skill) {
    setState(() {
      _skills.remove(skill);
    });
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    if (_skills.isEmpty) {
      CustomSnackBar.showError(context, 'Please add at least one skill tag.');
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final workerProvider = context.read<WorkerProvider>();
    final user = authProvider.currentUser;

    if (user == null) {
      context.go(RouteNames.login);
      return;
    }

    // 1. Ensure worker role is persisted to users/{uid}.roles before creating the worker profile
    if (!user.roles.contains(AppConstants.roleWorker)) {
      final enrolled = await authProvider.enrollRole(AppConstants.roleWorker);
      if (!enrolled) {
        if (!mounted) return;
        final errorMsg = authProvider.errorMessage ?? 'Failed to enroll worker capability.';
        CustomSnackBar.showError(context, errorMsg);
        return;
      }
    }

    final existingProfile = authProvider.workerProfile;
    final now = DateTime.now();
    final worker = WorkerModel(
      uid: user.uid,
      fullName: user.fullName,
      headline: _headlineController.text.trim(),
      description: _descController.text.trim(),
      skills: _skills,
      category: _selectedCategory,
      experienceYears: int.tryParse(_experienceController.text.trim()) ?? 1,
      city: _cityController.text.trim(),
      state: _stateController.text.trim(),
      locality: _localityController.text.trim(),
      rate: double.tryParse(_rateController.text.trim()) ?? 0.0,
      rateType: _rateType,
      availability: _availability,
      photoUrl: user.photoUrl,
      portfolioImageUrls: existingProfile?.portfolioImageUrls ?? [],
      averageRating: existingProfile?.averageRating ?? 0.0,
      reviewCount: existingProfile?.reviewCount ?? 0,
      profileStatus: 'completed',
      contactPhone: _phoneController.text.trim().isNotEmpty ? _phoneController.text.trim() : null,
      createdAt: existingProfile?.createdAt ?? now,
      updatedAt: now,
    );

    final success = await workerProvider.saveProfile(worker);

    if (!mounted) return;

    if (success) {
      authProvider.setWorkerProfile(worker);
      if (authProvider.currentUser?.activeRole != AppConstants.roleWorker) {
        await authProvider.switchPortal(AppConstants.roleWorker);
      }
      if (!mounted) return;
      CustomSnackBar.showSuccess(context, 'Worker profile published successfully!');
      context.go(RouteNames.workerDashboard);
    } else {
      final msg = workerProvider.errorMessage ?? 'Failed to save worker profile.';
      CustomSnackBar.showError(context, msg);
    }
  }

  @override
  Widget build(BuildContext context) {
    final workerProvider = context.watch<WorkerProvider>();

    return Scaffold(
      backgroundColor: AppColors.warmCream,
      appBar: AppBar(
        title: const Text('Worker Profile Setup', style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          TextButton(
            onPressed: () => context.go(RouteNames.customerDashboard),
            child: const Text('Skip For Now'),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: MaxWidthContainer(
            maxWidth: 680,
            child: AppCard(
              padding: const EdgeInsets.all(32),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Complete Your Professional Profile',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.charcoal,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Help local customers discover your craftsmanship, skills, and rates.',
                      style: TextStyle(fontSize: 14, color: AppColors.secondaryGrey),
                    ),
                    const SizedBox(height: 28),

                    // Primary Category
                    const Text('Primary Service Category', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
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

                    // Professional Headline
                    AppTextField(
                      controller: _headlineController,
                      label: 'Professional Headline',
                      hint: 'e.g. Master Carpenter with 10+ Years in Custom Furniture',
                      prefixIcon: Icons.badge_outlined,
                      validator: (val) => Validators.validateRequired(val, 'Headline'),
                    ),
                    const SizedBox(height: 18),

                    // Experience & Rate Row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: AppTextField(
                            controller: _experienceController,
                            label: 'Experience (Years)',
                            hint: 'e.g. 5',
                            prefixIcon: Icons.history_rounded,
                            keyboardType: TextInputType.number,
                            validator: (val) => Validators.validateNumber(val, 'Experience'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: AppTextField(
                            controller: _rateController,
                            label: 'Base Rate (₹)',
                            hint: 'e.g. 450',
                            prefixIcon: Icons.currency_rupee_rounded,
                            keyboardType: TextInputType.number,
                            validator: (val) => Validators.validateNumber(val, 'Rate'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Rate Type & Availability Row
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Billing Frequency', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
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
                                    value: _rateType,
                                    isExpanded: true,
                                    items: const [
                                      DropdownMenuItem(value: AppConstants.rateTypeHourly, child: Text('Per Hour')),
                                      DropdownMenuItem(value: AppConstants.rateTypeDaily, child: Text('Per Day')),
                                      DropdownMenuItem(value: AppConstants.rateTypeFixed, child: Text('Fixed / Quote')),
                                    ],
                                    onChanged: (val) {
                                      if (val != null) setState(() => _rateType = val);
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Availability', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
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
                                    value: _availability,
                                    isExpanded: true,
                                    items: AppConstants.availabilityOptions.map((a) {
                                      return DropdownMenuItem(value: a, child: Text(a, style: const TextStyle(fontSize: 13)));
                                    }).toList(),
                                    onChanged: (val) {
                                      if (val != null) setState(() => _availability = val);
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

                    // Location Fields: City & State & Locality
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
                      controller: _localityController,
                      label: 'Locality / Sector / Neighborhood',
                      hint: 'e.g. Indiranagar, HSR Layout, Sector 62',
                      prefixIcon: Icons.pin_drop_outlined,
                      validator: (val) => Validators.validateRequired(val, 'Locality'),
                    ),
                    const SizedBox(height: 18),

                    // Skills Tags Input
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Specialized Skills & Tags', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _skillInputController,
                                decoration: const InputDecoration(
                                  hintText: 'e.g. AC Installation, Wiring, Polishing',
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

                    // About / Description
                    AppTextField(
                      controller: _descController,
                      label: 'About Your Craft & Services',
                      hint: 'Describe your expertise, work approach, quality guarantees, and equipment...',
                      prefixIcon: Icons.description_outlined,
                      maxLines: 4,
                      validator: (val) => Validators.validateRequired(val, 'Service Description'),
                    ),
                    const SizedBox(height: 18),

                    // Contact Phone
                    AppTextField(
                      controller: _phoneController,
                      label: 'Contact Phone (Visible upon service booking)',
                      hint: 'e.g. 9876543210',
                      prefixIcon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      validator: Validators.validatePhone,
                    ),
                    const SizedBox(height: 32),

                    // Save Profile Button
                    AppButton(
                      label: 'Save & Publish Profile',
                      icon: Icons.check_circle_outline,
                      isLoading: workerProvider.isLoading,
                      onPressed: _handleSave,
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

