import 'package:firebase_auth/firebase_auth.dart';
import '../core/constants/app_constants.dart';
import '../core/exceptions/app_exception.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class AuthRepository {
  final AuthService _authService;
  final FirestoreService _firestoreService;

  AuthRepository({
    AuthService? authService,
    FirestoreService? firestoreService,
  })  : _authService = authService ?? AuthService(),
        _firestoreService = firestoreService ?? FirestoreService();

  User? get currentFirebaseUser => _authService.currentUser;
  Stream<User?> get authStateChanges => _authService.authStateChanges;

  Future<UserModel?> getUserProfile(String uid) async {
    try {
      final doc = await _firestoreService.getDocument(_firestoreService.users, uid);
      if (!doc.exists || doc.data() == null) {
        return null;
      }
      return UserModel.fromMap(doc.data() as Map<String, dynamic>, docId: doc.id);
    } catch (e) {
      throw DatabaseException('Failed to fetch user profile: $e');
    }
  }

  Future<UserModel> registerWithEmailAndPassword({
    required String fullName,
    required String email,
    required String password,
    required List<String> initialRoles,
    required String initialActiveRole,
  }) async {
    // Validate roles strictly
    for (final role in initialRoles) {
      if (!AppConstants.validRoles.contains(role)) {
        throw const ValidationException('Invalid role specified. Only customer and worker are allowed.');
      }
    }
    if (!initialRoles.contains(initialActiveRole)) {
      throw const ValidationException('Active role must be one of the selected roles.');
    }

    final credential = await _authService.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = credential.user;
    if (user == null) {
      throw const AuthException('Registration failed: no user returned.');
    }

    // Update display name
    await user.updateDisplayName(fullName);

    final now = DateTime.now();
    final userProfile = UserModel(
      uid: user.uid,
      fullName: fullName.trim(),
      email: email.trim().toLowerCase(),
      activeRole: initialActiveRole,
      roles: initialRoles,
      accountStatus: 'active',
      createdAt: now,
      updatedAt: now,
    );

    await _firestoreService.setDocument(
      _firestoreService.users,
      user.uid,
      userProfile.toMap(),
    );

    return userProfile;
  }

  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final credential = await _authService.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = credential.user;
    if (user == null) {
      throw const AuthException('Sign in failed: no user returned.');
    }

    final profile = await getUserProfile(user.uid);
    if (profile == null) {
      // Profile doc missing, create default customer profile
      final now = DateTime.now();
      final defaultProfile = UserModel(
        uid: user.uid,
        fullName: user.displayName ?? 'Skill-Link User',
        email: user.email ?? email,
        activeRole: AppConstants.roleCustomer,
        roles: [AppConstants.roleCustomer],
        createdAt: now,
        updatedAt: now,
      );
      await _firestoreService.setDocument(
        _firestoreService.users,
        user.uid,
        defaultProfile.toMap(),
      );
      return defaultProfile;
    }

    return profile;
  }

  Future<void> switchActiveRole(String uid, String newRole) async {
    if (!AppConstants.validRoles.contains(newRole)) {
      throw const ValidationException('Invalid role specified.');
    }

    final profile = await getUserProfile(uid);
    if (profile == null) {
      throw const DatabaseException('User profile not found.');
    }

    if (!profile.roles.contains(newRole)) {
      throw ValidationException('User does not have the $newRole role enabled.');
    }

    await _firestoreService.updateDocument(
      _firestoreService.users,
      uid,
      {
        'activeRole': newRole,
        'updatedAt': DateTime.now(),
      },
    );
  }

  Future<UserModel> addRole({
    required String uid,
    required String newRole,
  }) async {
    if (!AppConstants.validRoles.contains(newRole)) {
      throw const ValidationException('Invalid role. Only customer and worker can be enrolled.');
    }

    final profile = await getUserProfile(uid);
    if (profile == null) {
      throw const DatabaseException('User profile not found.');
    }

    if (profile.roles.contains(newRole)) {
      return profile;
    }

    final updatedRoles = List<String>.from(profile.roles)..add(newRole);

    await _firestoreService.updateDocument(
      _firestoreService.users,
      uid,
      {
        'roles': updatedRoles,
        'activeRole': newRole, // Automatically switch to the newly enrolled role
        'updatedAt': DateTime.now(),
      },
    );

    return profile.copyWith(
      roles: updatedRoles,
      activeRole: newRole,
      updatedAt: DateTime.now(),
    );
  }

  Future<void> updateProfile({
    required String uid,
    String? fullName,
    String? phone,
    String? photoUrl,
  }) async {
    final updates = <String, dynamic>{
      'updatedAt': DateTime.now(),
    };
    if (fullName != null) updates['fullName'] = fullName.trim();
    if (phone != null) updates['phone'] = phone.trim();
    if (photoUrl != null) updates['photoUrl'] = photoUrl;

    await _firestoreService.updateDocument(
      _firestoreService.users,
      uid,
      updates,
    );
  }

  Future<void> sendPasswordReset(String email) async {
    await _authService.sendPasswordResetEmail(email);
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }
}
