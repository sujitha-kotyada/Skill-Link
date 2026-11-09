import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/responsive_layout.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/custom_snackbar.dart';
import '../../../core/widgets/indian_location_selector.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/worker_provider.dart';

class EditWorkerProfileScreen extends StatefulWidget {
  const EditWorkerProfileScreen({super.key});

  @override
  State<EditWorkerProfileScreen> createState() => _EditWorkerProfileScreenState();
}

class _EditWorkerProfileScreenState extends State<EditWorkerProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final _headlineController = TextEditingController();
  final _descController = TextEditingController();
  final _skillInputController = TextEditingController();
  final _experienceController = TextEditingController();
  final _localityController = TextEditingController();
  final _rateController = TextEditingController();
  final _phoneController = TextEditingController();

  String? _selectedState;
  String? _selectedCity;
  String _selectedCategory = AppConstants.categoryElectrician;
  String _rateType = AppConstants.rateTypeHourly;
  String _availability = AppConstants.availabilityOptions.first;
  final List<String> _skills = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      final p = auth.workerProfile;
      if (p != null) {
        _headlineController.text = p.headline;
        _descController.text = p.description;
        _experienceController.text = p.experienceYears.toString();
        _localityController.text = p.locality;
        _rateController.text = p.rate.toStringAsFixed(0);
        _phoneController.text = p.contactPhone ?? '';
        setState(() {
          _selectedState = p.state.isNotEmpty ? p.state : null;
          _selectedCity = p.city.isNotEmpty ? p.city : null;
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
    setState(() => _skills.remove(skill));
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
    final existing = authProvider.workerProfile;

    if (user == null || existing == null) return;

    final updated = existing.copyWith(
      headline: _headlineController.text.trim(),
      description: _descController.text.trim(),
      skills: _skills,
      category: _selectedCategory,
      experienceYears: int.tryParse(_experienceController.text.trim()) ?? existing.experienceYears,
      city: _selectedCity ?? existing.city,
      state: _selectedState ?? existing.state,
      locality: _localityController.text.trim(),
      rate: double.tryParse(_rateController.text.trim()) ?? existing.rate,
      rateType: _rateType,
      availability: _availability,
      contactPhone: _phoneController.text.trim().isNotEmpty ? _phoneController.text.trim() : null,
      updatedAt: DateTime.now(),
    );

    final success = await workerProvider.saveProfile(updated);

    if (!mounted) return;

    if (success) {
      authProvider.setWorkerProfile(updated);
      CustomSnackBar.showSuccess(context, 'Profile updated successfully!');
      context.pop();
    } else {
      final msg = workerProvider.errorMessage ?? 'Failed to update profile.';
      CustomSnackBar.showError(context, msg);
    }
  }

  @override
  Widget build(BuildContext context) {
    final workerProvider = context.watch<WorkerProvider>();

    return Scaffold(
      backgroundColor: AppColors.warmCream,
      appBar: AppBar(
        title: const Text('Edit Worker Profile', style: TextStyle(fontWeight: FontWeight.w700)),
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
                            return DropdownMenuItem(value: c, child: Text(c));
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedCategory = val);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    AppTextField(
                      controller: _headlineController,
                      label: 'Professional Headline',
                      validator: (val) => Validators.validateRequired(val, 'Headline'),
                    ),
                    const SizedBox(height: 18),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: AppTextField(
                            controller: _experienceController,
                            label: 'Experience (Years)',
                            keyboardType: TextInputType.number,
                            validator: (val) => Validators.validateNumber(val, 'Experience'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: AppTextField(
                            controller: _rateController,
                            label: 'Rate (₹)',
                            keyboardType: TextInputType.number,
                            validator: (val) => Validators.validateNumber(val, 'Rate'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

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
                                      DropdownMenuItem(value: AppConstants.rateTypeFixed, child: Text('Fixed')),
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

                    IndianLocationSelector(
                      initialSelectedState: _selectedState,
                      initialSelectedCity: _selectedCity,
                      onStateChanged: (val) => setState(() => _selectedState = val),
                      onCityChanged: (val) => setState(() => _selectedCity = val),
                    ),
                    const SizedBox(height: 18),
                    AppTextField(
                      controller: _localityController,
                      label: 'Locality / Sector',
                      validator: (val) => Validators.validateRequired(val, 'Locality'),
                    ),
                    const SizedBox(height: 18),

                    // Skills
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Specialized Skills', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _skillInputController,
                                decoration: const InputDecoration(hintText: 'Add another skill...'),
                                onSubmitted: (_) => _addSkill(),
                              ),
                            ),
                            const SizedBox(width: 10),
                            IconButton.filled(
                              icon: const Icon(Icons.add),
                              style: IconButton.styleFrom(backgroundColor: AppColors.terracotta),
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
                                backgroundColor: const Color(0xFFFBE9E7),
                                side: BorderSide.none,
                              );
                            }).toList(),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 18),

                    AppTextField(
                      controller: _descController,
                      label: 'Service Description & Bio',
                      maxLines: 4,
                      validator: (val) => Validators.validateRequired(val, 'Description'),
                    ),
                    const SizedBox(height: 18),

                    AppTextField(
                      controller: _phoneController,
                      label: 'Direct Contact Phone',
                      keyboardType: TextInputType.phone,
                      validator: Validators.validatePhone,
                    ),
                    const SizedBox(height: 32),

                    AppButton(
                      label: 'Save Changes',
                      icon: Icons.check,
                      isLoading: workerProvider.isLoading,
                      onPressed: _handleSave,
                      isFullWidth: true,
                      variant: AppButtonVariant.secondary,
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
