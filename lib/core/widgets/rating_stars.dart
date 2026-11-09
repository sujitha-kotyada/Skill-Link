import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class RatingStars extends StatelessWidget {
  final double rating;
  final int reviewCount;
  final double starSize;
  final bool showCount;

  const RatingStars({
    super.key,
    required this.rating,
    this.reviewCount = 0,
    this.starSize = 16.0,
    this.showCount = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          Icons.star_rounded,
          size: starSize,
          color: AppColors.mutedSaffron,
        ),
        const SizedBox(width: 4),
        Text(
          rating.toStringAsFixed(1),
          style: TextStyle(
            fontSize: starSize * 0.9,
            fontWeight: FontWeight.w700,
            color: AppColors.charcoal,
          ),
        ),
        if (showCount) ...[
          const SizedBox(width: 4),
          Text(
            '($reviewCount)',
            style: TextStyle(
              fontSize: starSize * 0.8,
              color: AppColors.secondaryGrey,
            ),
          ),
        ],
      ],
    );
  }
}

class InteractiveRatingBar extends StatelessWidget {
  final int rating;
  final ValueChanged<int> onRatingChanged;
  final double starSize;

  const InteractiveRatingBar({
    super.key,
    required this.rating,
    required this.onRatingChanged,
    this.starSize = 32.0,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starIndex = index + 1;
        return IconButton(
          iconSize: starSize,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          icon: Icon(
            starIndex <= rating ? Icons.star_rounded : Icons.star_outline_rounded,
            color: AppColors.mutedSaffron,
          ),
          onPressed: () => onRatingChanged(starIndex),
        );
      }),
    );
  }
}

