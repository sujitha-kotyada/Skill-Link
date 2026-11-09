import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/app_constants.dart';

class ApplicationModel {
  final String id;
  final String jobId;
  final String jobTitle;
  final String customerId;
  final String workerId;
  final String workerName;
  final String workerCategory;
  final String? workerPhotoUrl;
  final double workerAverageRating;
  final String workerHeadline;
  final List<String> workerSkills;
  final int workerExperienceYears;
  final String workerLocation;
  final String message;
  final double proposedRate;
  final String proposedRateType;
  final String status; // 'applied', 'under_review', 'accepted', 'rejected', 'withdrawn'
  final DateTime createdAt;
  final DateTime updatedAt;

  ApplicationModel({
    required this.id,
    required this.jobId,
    required this.jobTitle,
    required this.customerId,
    required this.workerId,
    required this.workerName,
    required this.workerCategory,
    this.workerPhotoUrl,
    this.workerAverageRating = 0.0,
    this.workerHeadline = '',
    this.workerSkills = const [],
    this.workerExperienceYears = 0,
    this.workerLocation = '',
    required this.message,
    required this.proposedRate,
    this.proposedRateType = AppConstants.rateTypeFixed,
    this.status = AppConstants.appStatusApplied,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isApplied => status == AppConstants.appStatusApplied;
  bool get isUnderReview => status == AppConstants.appStatusUnderReview;
  bool get isAccepted => status == AppConstants.appStatusAccepted;
  bool get isRejected => status == AppConstants.appStatusRejected;
  bool get isWithdrawn => status == AppConstants.appStatusWithdrawn;

  ApplicationModel copyWith({
    String? id,
    String? jobId,
    String? jobTitle,
    String? customerId,
    String? workerId,
    String? workerName,
    String? workerCategory,
    String? workerPhotoUrl,
    double? workerAverageRating,
    String? workerHeadline,
    List<String>? workerSkills,
    int? workerExperienceYears,
    String? workerLocation,
    String? message,
    double? proposedRate,
    String? proposedRateType,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ApplicationModel(
      id: id ?? this.id,
      jobId: jobId ?? this.jobId,
      jobTitle: jobTitle ?? this.jobTitle,
      customerId: customerId ?? this.customerId,
      workerId: workerId ?? this.workerId,
      workerName: workerName ?? this.workerName,
      workerCategory: workerCategory ?? this.workerCategory,
      workerPhotoUrl: workerPhotoUrl ?? this.workerPhotoUrl,
      workerAverageRating: workerAverageRating ?? this.workerAverageRating,
      workerHeadline: workerHeadline ?? this.workerHeadline,
      workerSkills: workerSkills ?? this.workerSkills,
      workerExperienceYears: workerExperienceYears ?? this.workerExperienceYears,
      workerLocation: workerLocation ?? this.workerLocation,
      message: message ?? this.message,
      proposedRate: proposedRate ?? this.proposedRate,
      proposedRateType: proposedRateType ?? this.proposedRateType,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'jobId': jobId,
      'jobTitle': jobTitle,
      'customerId': customerId,
      'workerId': workerId,
      'workerName': workerName,
      'workerCategory': workerCategory,
      'workerPhotoUrl': workerPhotoUrl,
      'workerAverageRating': workerAverageRating,
      'workerHeadline': workerHeadline,
      'workerSkills': workerSkills,
      'workerExperienceYears': workerExperienceYears,
      'workerLocation': workerLocation,
      'message': message,
      'proposedRate': proposedRate,
      'proposedRateType': proposedRateType,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory ApplicationModel.fromMap(Map<String, dynamic> map, {required String docId}) {
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    final rawSkills = map['workerSkills'];
    List<String> parsedSkills = [];
    if (rawSkills is List) {
      parsedSkills = rawSkills.map((e) => e.toString()).toList();
    }

    return ApplicationModel(
      id: docId,
      jobId: map['jobId'] ?? '',
      jobTitle: map['jobTitle'] ?? 'Job Application',
      customerId: map['customerId'] ?? '',
      workerId: map['workerId'] ?? '',
      workerName: map['workerName'] ?? 'Worker',
      workerCategory: map['workerCategory'] ?? '',
      workerPhotoUrl: map['workerPhotoUrl'],
      workerAverageRating: (map['workerAverageRating'] as num?)?.toDouble() ?? 0.0,
      workerHeadline: map['workerHeadline'] ?? '',
      workerSkills: parsedSkills,
      workerExperienceYears: (map['workerExperienceYears'] as num?)?.toInt() ?? 0,
      workerLocation: map['workerLocation'] ?? '',
      message: map['message'] ?? '',
      proposedRate: (map['proposedRate'] as num?)?.toDouble() ?? 0.0,
      proposedRateType: map['proposedRateType'] ?? AppConstants.rateTypeFixed,
      status: map['status'] ?? AppConstants.appStatusApplied,
      createdAt: parseDate(map['createdAt']),
      updatedAt: parseDate(map['updatedAt']),
    );
  }
}

