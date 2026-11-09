import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/responsive_layout.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/custom_snackbar.dart';
import '../../../core/widgets/rating_stars.dart';
import '../../../models/review_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../repositories/review_repository.dart';

class WriteReviewScreen extends StatefulWidget {
  final String jobId;
  final String workerId;
  final String jobTitle;

  const WriteReviewScreen({
    super.key,
    required this.jobId,
    required this.workerId,
    required this.jobTitle,
  });

  @override
  State<WriteReviewScreen> createState() => _WriteReviewScreenState();
}

class _WriteReviewScreenState extends State<WriteReviewScreen> {
  final _formKey = GlobalKey<FormState>();
  final _commentController = TextEditingController();
  int _rating = 5;
  bool _isSubmitting = false;
  final _reviewRepository = ReviewRepository();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final user = authProvider.currentUser;

    if (user == null) {
      CustomSnackBar.showError(context, 'Please sign in to submit a review.');
      return;
    }

    if (user.uid == widget.workerId) {
      CustomSnackBar.showError(context, 'You cannot review your own profile.');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final review = ReviewModel(
        id: '',
        customerId: user.uid,
        customerName: user.fullName,
        workerId: widget.workerId,
        jobId: widget.jobId,
        jobTitle: widget.jobTitle,
        rating: _rating.toDouble(),
        comment: _commentController.text.trim(),
        createdAt: DateTime.now(),
      );

      await _reviewRepository.submitReview(review);

      if (!mounted) return;
      setState(() => _isSubmitting = false);
      CustomSnackBar.showSuccess(context, 'Thank you! Your review has been published.');
      context.pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      CustomSnackBar.showError(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmCream,
      appBar: AppBar(
        title: const Text('Write a Review', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: MaxWidthContainer(
            maxWidth: 600,
            child: AppCard(
              padding: const EdgeInsets.all(32),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Rate Your Service Experience',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.charcoal,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'For "${widget.jobTitle}"',
                      style: const TextStyle(fontSize: 14, color: AppColors.secondaryGrey),
                    ),
                    const SizedBox(height: 28),

                    // Star Rating Picker
                    Center(
                      child: Column(
                        children: [
                          InteractiveRatingBar(
                            rating: _rating,
                            starSize: 42,
                            onRatingChanged: (val) => setState(() => _rating = val),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _getRatingDescription(_rating),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryTeal,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Written Feedback
                    AppTextField(
                      controller: _commentController,
                      label: 'Your Detailed Feedback',
                      hint: 'Describe punctuality, quality of work, cleanliness, and overall experience...',
                      prefixIcon: Icons.rate_review_outlined,
                      maxLines: 5,
                      validator: (val) => Validators.validateRequired(val, 'Feedback comment'),
                    ),
                    const SizedBox(height: 32),

                    AppButton(
                      label: 'Submit Review',
                      icon: Icons.check_circle_rounded,
                      isLoading: _isSubmitting,
                      onPressed: _handleSubmit,
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

  String _getRatingDescription(int rating) {
    switch (rating) {
      case 5:
        return '5 Stars • Excellent Craftsmanship!';
      case 4:
        return '4 Stars • Very Good Service';
      case 3:
        return '3 Stars • Average Experience';
      case 2:
        return '2 Stars • Below Expectations';
      case 1:
        return '1 Star • Poor Experience';
      default:
        return '';
    }
  }
}
