import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/app_constants.dart';

class UserModel {
  final String uid;
  final String fullName;
  final String email;
  final String? photoUrl;
  final String? phone;
  final String activeRole; // 'customer' or 'worker'
  final List<String> roles; // ['customer'], ['worker'], or ['customer', 'worker']
  final String accountStatus; // 'active', 'suspended', etc.
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.uid,
    required this.fullName,
    required this.email,
    this.photoUrl,
    this.phone,
    required this.activeRole,
    required this.roles,
    this.accountStatus = 'active',
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isCustomer => roles.contains(AppConstants.roleCustomer);
  bool get isWorker => roles.contains(AppConstants.roleWorker);
  bool get hasBothRoles => isCustomer && isWorker;
  bool get isCustomerActive => activeRole == AppConstants.roleCustomer;
  bool get isWorkerActive => activeRole == AppConstants.roleWorker;

  bool canSwitchTo(String role) => roles.contains(role);

  UserModel copyWith({
    String? uid,
    String? fullName,
    String? email,
    String? photoUrl,
    String? phone,
    String? activeRole,
    List<String>? roles,
    String? accountStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      phone: phone ?? this.phone,
      activeRole: activeRole ?? this.activeRole,
      roles: roles ?? this.roles,
      accountStatus: accountStatus ?? this.accountStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'photoUrl': photoUrl,
      'phone': phone,
      'activeRole': activeRole,
      'roles': roles,
      'accountStatus': accountStatus,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map, {String? docId}) {
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    final rawRoles = map['roles'];
    List<String> parsedRoles = [];
    if (rawRoles is List) {
      parsedRoles = rawRoles.map((e) => e.toString()).toList();
    }
    if (parsedRoles.isEmpty) {
      parsedRoles = [map['activeRole'] ?? AppConstants.roleCustomer];
    }

    return UserModel(
      uid: docId ?? (map['uid'] ?? ''),
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      photoUrl: map['photoUrl'],
      phone: map['phone'],
      activeRole: map['activeRole'] ?? AppConstants.roleCustomer,
      roles: parsedRoles,
      accountStatus: map['accountStatus'] ?? 'active',
      createdAt: parseDate(map['createdAt']),
      updatedAt: parseDate(map['updatedAt']),
    );
  }
}
