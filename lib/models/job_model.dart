import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/app_constants.dart';

class JobModel {
  final String id;
  final String customerId;
  final String customerName;
  final String title;
  final String category;
  final String description;
  final List<String> requiredSkills;
  final String location;
  final String city;
  final String state;
  final String? preferredDate;
  final double budget;
  final String paymentType; // 'fixed' or 'hourly'
  final String? additionalInstructions;
  final String status; // 'open', 'in_progress', 'completed', 'cancelled'
  final int applicantCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  JobModel({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.title,
    required this.category,
    required this.description,
    this.requiredSkills = const [],
    required this.location,
    required this.city,
    required this.state,
    this.preferredDate,
    required this.budget,
    this.paymentType = AppConstants.rateTypeFixed,
    this.additionalInstructions,
    this.status = AppConstants.jobStatusOpen,
    this.applicantCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isOpen => status == AppConstants.jobStatusOpen;
  bool get isInProgress => status == AppConstants.jobStatusInProgress;
  bool get isCompleted => status == AppConstants.jobStatusCompleted;
  bool get isCancelled => status == AppConstants.jobStatusCancelled;

  JobModel copyWith({
    String? id,
    String? customerId,
    String? customerName,
    String? title,
    String? category,
    String? description,
    List<String>? requiredSkills,
    String? location,
    String? city,
    String? state,
    String? preferredDate,
    double? budget,
    String? paymentType,
    String? additionalInstructions,
    String? status,
    int? applicantCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return JobModel(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      title: title ?? this.title,
      category: category ?? this.category,
      description: description ?? this.description,
      requiredSkills: requiredSkills ?? this.requiredSkills,
      location: location ?? this.location,
      city: city ?? this.city,
      state: state ?? this.state,
      preferredDate: preferredDate ?? this.preferredDate,
      budget: budget ?? this.budget,
      paymentType: paymentType ?? this.paymentType,
      additionalInstructions: additionalInstructions ?? this.additionalInstructions,
      status: status ?? this.status,
      applicantCount: applicantCount ?? this.applicantCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'customerId': customerId,
      'customerName': customerName,
      'title': title,
      'category': category,
      'description': description,
      'requiredSkills': requiredSkills,
      'location': location,
      'city': city,
      'state': state,
      'preferredDate': preferredDate,
      'budget': budget,
      'paymentType': paymentType,
      'additionalInstructions': additionalInstructions,
      'status': status,
      'applicantCount': applicantCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory JobModel.fromMap(Map<String, dynamic> map, {required String docId}) {
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    final rawSkills = map['requiredSkills'];
    List<String> parsedSkills = [];
    if (rawSkills is List) {
      parsedSkills = rawSkills.map((e) => e.toString()).toList();
    }

    return JobModel(
      id: docId,
      customerId: map['customerId'] ?? '',
      customerName: map['customerName'] ?? 'Customer',
      title: map['title'] ?? '',
      category: map['category'] ?? AppConstants.categoryOther,
      description: map['description'] ?? '',
      requiredSkills: parsedSkills,
      location: map['location'] ?? '',
      city: map['city'] ?? '',
      state: map['state'] ?? '',
      preferredDate: map['preferredDate'],
      budget: (map['budget'] as num?)?.toDouble() ?? 0.0,
      paymentType: map['paymentType'] ?? AppConstants.rateTypeFixed,
      additionalInstructions: map['additionalInstructions'],
      status: map['status'] ?? AppConstants.jobStatusOpen,
      applicantCount: (map['applicantCount'] as num?)?.toInt() ?? 0,
      createdAt: parseDate(map['createdAt']),
      updatedAt: parseDate(map['updatedAt']),
    );
  }
}

