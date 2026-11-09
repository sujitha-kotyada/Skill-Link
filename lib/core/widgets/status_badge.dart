import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color text;
    String display;

    switch (status.toLowerCase()) {
      case 'open':
        bg = AppColors.tealSurface;
        text = AppColors.primaryTeal;
        display = 'Open';
        break;
      case 'in_progress':
        bg = const Color(0xFFFFF4E5);
        text = AppColors.mutedSaffron;
        display = 'In Progress';
        break;
      case 'completed':
        bg = const Color(0xFFE8F5E9);
        text = AppColors.successGreen;
        display = 'Completed';
        break;
      case 'cancelled':
        bg = const Color(0xFFFFEBEE);
        text = AppColors.errorRed;
        display = 'Cancelled';
        break;
      case 'applied':
        bg = const Color(0xFFE3F2FD);
        text = AppColors.infoBlue;
        display = 'Applied';
        break;
      case 'under_review':
        bg = const Color(0xFFFFF8E1);
        text = AppColors.mutedSaffron;
        display = 'Under Review';
        break;
      case 'accepted':
        bg = const Color(0xFFE8F5E9);
        text = AppColors.successGreen;
        display = 'Accepted';
        break;
      case 'rejected':
        bg = const Color(0xFFFFEBEE);
        text = AppColors.errorRed;
        display = 'Rejected';
        break;
      case 'withdrawn':
        bg = AppColors.lightGrey;
        text = AppColors.secondaryGrey;
        display = 'Withdrawn';
        break;
      default:
        bg = AppColors.lightGrey;
        text = AppColors.secondaryGrey;
        display = status.isNotEmpty ? status[0].toUpperCase() + status.substring(1) : status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        display,
        style: TextStyle(
          color: text,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
