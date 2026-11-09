import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/utils/responsive_layout.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/custom_snackbar.dart';
import '../../../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _enableCustomerRole = true;
  bool _enableWorkerRole = false;
  String _activePortalChoice = AppConstants.roleCustomer;
  bool _acceptedTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_enableCustomerRole && !_enableWorkerRole) {
      CustomSnackBar.showError(context, 'Please select at least one role to continue.');
      return;
    }

    if (!_acceptedTerms) {
      CustomSnackBar.showError(context, 'You must accept the terms and conditions to register.');
      return;
    }

    final List<String> selectedRoles = [];
    if (_enableCustomerRole) selectedRoles.add(AppConstants.roleCustomer);
    if (_enableWorkerRole) selectedRoles.add(AppConstants.roleWorker);

    final initialActiveRole = selectedRoles.contains(_activePortalChoice)
        ? _activePortalChoice
        : selectedRoles.first;

    final authProvider = context.read<AuthProvider>();
    final email = _emailController.text.trim();
    final success = await authProvider.register(
      fullName: _nameController.text.trim(),
      email: email,
      password: _passwordController.text,
      initialRoles: selectedRoles,
      initialActiveRole: initialActiveRole,
    );

    if (!mounted) return;

    if (success) {
      // Success feedback
      CustomSnackBar.showSuccess(
        context,
        'Account created successfully! Please sign in to continue.',
      );

      // Navigate to the Login page and preserve the registered email address
      context.go(RouteNames.login, extra: email);
    } else {
      final errorMsg = authProvider.errorMessage ?? 'Registration failed. Please try again.';
      CustomSnackBar.showError(context, errorMsg);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.warmCream,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go(RouteNames.landing),
        ),
        title: const Text(
          'Create Account',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: MaxWidthContainer(
              maxWidth: 520,
              child: AppCard(
                padding: const EdgeInsets.all(32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        AppStrings.createAccount,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: AppColors.charcoal,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'One unified account gives you access to both hire local skills and offer your services.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.secondaryGrey,
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Full Name
                      AppTextField(
                        controller: _nameController,
                        label: 'Full Name',
                        hint: 'e.g. Ramesh Kumar',
                        prefixIcon: Icons.person_outline_rounded,
                        validator: (val) => Validators.validateRequired(val, 'Full Name'),
                      ),
                      const SizedBox(height: 18),

                      // Email Address
                      AppTextField(
                        controller: _emailController,
                        label: 'Email Address',
                        hint: 'name@example.com',
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: Validators.validateEmail,
                      ),
                      const SizedBox(height: 18),

                      // Password
                      AppTextField(
                        controller: _passwordController,
                        label: 'Password',
                        hint: 'Minimum 6 characters',
                        prefixIcon: Icons.lock_outline_rounded,
                        isPassword: true,
                        validator: Validators.validatePassword,
                      ),
                      const SizedBox(height: 18),

                      // Confirm Password
                      AppTextField(
                        controller: _confirmPasswordController,
                        label: 'Confirm Password',
                        hint: 'Re-enter your password',
                        prefixIcon: Icons.lock_reset_rounded,
                        isPassword: true,
                        validator: (val) =>
                            Validators.validateConfirmPassword(val, _passwordController.text),
                      ),
                      const SizedBox(height: 24),

                      // Role Capabilities Selection Box
                      const Text(
                        'Choose Your Platform Capabilities',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.charcoal,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'You can select both roles. Switch anytime without another account.',
                        style: TextStyle(fontSize: 12, color: AppColors.secondaryGrey),
                      ),
                      const SizedBox(height: 12),

                      // Customer Capability Checkbox Card
                      _buildRoleOption(
                        title: 'I want to hire local workers (Customer)',
                        subtitle: 'Post service requests, discover specialists, and hire.',
                        icon: Icons.person_search_rounded,
                        value: _enableCustomerRole,
                        onChanged: (val) {
                          setState(() {
                            _enableCustomerRole = val ?? false;
                          });
                        },
                      ),
                      const SizedBox(height: 10),

                      // Worker Capability Checkbox Card
                      _buildRoleOption(
                        title: 'I want to offer my skills (Worker)',
                        subtitle: 'Showcase craft, get discovered, and apply for opportunities.',
                        icon: Icons.handyman_rounded,
                        value: _enableWorkerRole,
                        onChanged: (val) {
                          setState(() {
                            _enableWorkerRole = val ?? false;
                          });
                        },
                      ),
                      const SizedBox(height: 20),

                      // If both chosen, let them pick initial starting portal
                      if (_enableCustomerRole && _enableWorkerRole) ...[
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.tealSurface,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Starting Portal Preference',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.deepForestTeal,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  ChoiceChip(
                                    label: const Text('Customer Portal'),
                                    selected: _activePortalChoice == AppConstants.roleCustomer,
                                    selectedColor: AppColors.primaryTeal,
                                    labelStyle: TextStyle(
                                      color: _activePortalChoice == AppConstants.roleCustomer ? AppColors.white : AppColors.charcoal,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    onSelected: (_) => setState(() => _activePortalChoice = AppConstants.roleCustomer),
                                  ),
                                  const SizedBox(width: 12),
                                  ChoiceChip(
                                    label: const Text('Worker Portal'),
                                    selected: _activePortalChoice == AppConstants.roleWorker,
                                    selectedColor: AppColors.terracotta,
                                    labelStyle: TextStyle(
                                      color: _activePortalChoice == AppConstants.roleWorker ? AppColors.white : AppColors.charcoal,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    onSelected: (_) => setState(() => _activePortalChoice = AppConstants.roleWorker),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Terms and conditions acceptance
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: Checkbox(
                              value: _acceptedTerms,
                              activeColor: AppColors.primaryTeal,
                              onChanged: (val) {
                                setState(() {
                                  _acceptedTerms = val ?? false;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text(
                              'I accept the Terms of Service, Community Guidelines, and Privacy Policy of Skill-Link.',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.charcoal,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),

                      // Submit Register Button
                      AppButton(
                        label: 'Create Account',
                        isLoading: authProvider.isLoading,
                        onPressed: _handleRegister,
                        isFullWidth: true,
                        variant: AppButtonVariant.primary,
                      ),
                      const SizedBox(height: 20),

                      // Login Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Already registered?',
                            style: TextStyle(fontSize: 14, color: AppColors.secondaryGrey),
                          ),
                          const SizedBox(width: 6),
                          InkWell(
                            onTap: () => context.go(RouteNames.login),
                            child: const Text(
                              'Sign In',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryTeal,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: value ? AppColors.tealSurface.withAlpha((0.5 * 255).round()) : AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: value ? AppColors.primaryTeal : AppColors.borderGrey,
          width: value ? 1.5 : 1,
        ),
      ),
      child: CheckboxListTile(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primaryTeal,
        secondary: Icon(icon, color: value ? AppColors.primaryTeal : AppColors.secondaryGrey),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: value ? AppColors.deepForestTeal : AppColors.charcoal,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: AppColors.secondaryGrey),
        ),
      ),
    );
  }
}
