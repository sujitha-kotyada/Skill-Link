import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'Skill-Link';
  static const String appTagline = 'Connecting Local Skills with Local Opportunities.';

  // Roles
  static const String roleCustomer = 'customer';
  static const String roleWorker = 'worker';
  static const List<String> validRoles = [roleCustomer, roleWorker];

  // Service Categories
  static const String categoryElectrician = 'Electrician';
  static const String categoryPlumber = 'Plumber';
  static const String categoryCarpenter = 'Carpenter';
  static const String categoryPainter = 'Painter';
  static const String categoryMechanic = 'Mechanic';
  static const String categoryTailor = 'Tailor';
  static const String categoryTutor = 'Tutor';
  static const String categoryCleaning = 'Cleaning Services';
  static const String categoryApplianceRepair = 'Home Appliance Repair';
  static const String categoryGardening = 'Gardening';
  static const String categoryOther = 'Other Skills';

  static const List<String> serviceCategories = [
    categoryElectrician,
    categoryPlumber,
    categoryCarpenter,
    categoryPainter,
    categoryMechanic,
    categoryTailor,
    categoryTutor,
    categoryCleaning,
    categoryApplianceRepair,
    categoryGardening,
    categoryOther,
  ];

  static IconData getCategoryIcon(String category) {
    switch (category) {
      case categoryElectrician:
        return Icons.electrical_services;
      case categoryPlumber:
        return Icons.plumbing;
      case categoryCarpenter:
        return Icons.carpenter;
      case categoryPainter:
        return Icons.format_paint;
      case categoryMechanic:
        return Icons.build;
      case categoryTailor:
        return Icons.content_cut;
      case categoryTutor:
        return Icons.school;
      case categoryCleaning:
        return Icons.cleaning_services;
      case categoryApplianceRepair:
        return Icons.home_repair_service;
      case categoryGardening:
        return Icons.yard;
      default:
        return Icons.work_outline;
    }
  }

  // Job Statuses
  static const String jobStatusOpen = 'open';
  static const String jobStatusInProgress = 'in_progress';
  static const String jobStatusCompleted = 'completed';
  static const String jobStatusCancelled = 'cancelled';

  // Application Statuses
  static const String appStatusApplied = 'applied';
  static const String appStatusUnderReview = 'under_review';
  static const String appStatusAccepted = 'accepted';
  static const String appStatusRejected = 'rejected';
  static const String appStatusWithdrawn = 'withdrawn';

  // Rate Types
  static const String rateTypeHourly = 'hourly';
  static const String rateTypeDaily = 'daily';
  static const String rateTypeFixed = 'fixed';

  // Availability Options
  static const List<String> availabilityOptions = [
    'Immediate (Full-time)',
    'Part-time / Flexible',
    'Weekends Only',
    'Emergency / On-demand',
  ];

  // Breakpoints
  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 1024.0;
  static const double maxContentWidth = 1200.0;
}
