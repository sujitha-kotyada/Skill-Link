import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/app_constants.dart';

class WorkerModel {
  final String uid;
  final String fullName;
  final String headline;
  final String description;
  final List<String> skills;
  final String category;
  final int experienceYears;
  final String city;
  final String state;
  final String locality;
  final double rate;
  final String rateType; // 'hourly', 'daily', 'fixed'
  final String availability;
  final String? photoUrl;
  final List<String> portfolioImageUrls;
  final double averageRating;
  final int reviewCount;
  final String profileStatus; // 'completed', 'incomplete'
  final String? contactPhone;
  final DateTime createdAt;
  final DateTime updatedAt;

  WorkerModel({
    required this.uid,
    required this.fullName,
    required this.headline,
    required this.description,
    required this.skills,
    required this.category,
    required this.experienceYears,
    required this.city,
    required this.state,
    required this.locality,
    required this.rate,
    this.rateType = AppConstants.rateTypeHourly,
    required this.availability,
    this.photoUrl,
    this.portfolioImageUrls = const [],
    this.averageRating = 0.0,
    this.reviewCount = 0,
    this.profileStatus = 'completed',
    this.contactPhone,
    required this.createdAt,
    required this.updatedAt,
  });

  String get locationString => locality.isNotEmpty ? '$locality, $city' : '$city, $state';

  WorkerModel copyWith({
    String? uid,
    String? fullName,
    String? headline,
    String? description,
    List<String>? skills,
    String? category,
    int? experienceYears,
    String? city,
    String? state,
    String? locality,
    double? rate,
    String? rateType,
    String? availability,
    String? photoUrl,
    List<String>? portfolioImageUrls,
    double? averageRating,
    int? reviewCount,
    String? profileStatus,
    String? contactPhone,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WorkerModel(
      uid: uid ?? this.uid,
      fullName: fullName ?? this.fullName,
      headline: headline ?? this.headline,
      description: description ?? this.description,
      skills: skills ?? this.skills,
      category: category ?? this.category,
      experienceYears: experienceYears ?? this.experienceYears,
      city: city ?? this.city,
      state: state ?? this.state,
      locality: locality ?? this.locality,
      rate: rate ?? this.rate,
      rateType: rateType ?? this.rateType,
      availability: availability ?? this.availability,
      photoUrl: photoUrl ?? this.photoUrl,
      portfolioImageUrls: portfolioImageUrls ?? this.portfolioImageUrls,
      averageRating: averageRating ?? this.averageRating,
      reviewCount: reviewCount ?? this.reviewCount,
      profileStatus: profileStatus ?? this.profileStatus,
      contactPhone: contactPhone ?? this.contactPhone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullName': fullName,
      'headline': headline,
      'description': description,
      'skills': skills,
      'category': category,
      'experienceYears': experienceYears,
      'city': city,
      'state': state,
      'locality': locality,
      'rate': rate,
      'rateType': rateType,
      'availability': availability,
      'photoUrl': photoUrl,
      'portfolioImageUrls': portfolioImageUrls,
      'averageRating': averageRating,
      'reviewCount': reviewCount,
      'profileStatus': profileStatus,
      'contactPhone': contactPhone,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory WorkerModel.fromMap(Map<String, dynamic> map, {String? docId}) {
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    final rawSkills = map['skills'];
    List<String> parsedSkills = [];
    if (rawSkills is List) {
      parsedSkills = rawSkills.map((e) => e.toString()).toList();
    }

    final rawPortfolio = map['portfolioImageUrls'];
    List<String> parsedPortfolio = [];
    if (rawPortfolio is List) {
      parsedPortfolio = rawPortfolio.map((e) => e.toString()).toList();
    }

    return WorkerModel(
      uid: docId ?? (map['uid'] ?? ''),
      fullName: map['fullName'] ?? '',
      headline: map['headline'] ?? '',
      description: map['description'] ?? '',
      skills: parsedSkills,
      category: map['category'] ?? AppConstants.categoryOther,
      experienceYears: (map['experienceYears'] as num?)?.toInt() ?? 0,
      city: map['city'] ?? '',
      state: map['state'] ?? '',
      locality: map['locality'] ?? '',
      rate: (map['rate'] as num?)?.toDouble() ?? 0.0,
      rateType: map['rateType'] ?? AppConstants.rateTypeHourly,
      availability: map['availability'] ?? 'Immediate (Full-time)',
      photoUrl: map['photoUrl'],
      portfolioImageUrls: parsedPortfolio,
      averageRating: (map['averageRating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (map['reviewCount'] as num?)?.toInt() ?? 0,
      profileStatus: map['profileStatus'] ?? 'completed',
      contactPhone: map['contactPhone'],
      createdAt: parseDate(map['createdAt']),
      updatedAt: parseDate(map['updatedAt']),
    );
  }
}
