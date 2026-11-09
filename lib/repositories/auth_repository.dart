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
      if (e is AppException) rethrow;
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
    // 1. Validate roles strictly
    for (final role in initialRoles) {
      if (!AppConstants.validRoles.contains(role)) {
        throw const ValidationException('Invalid role specified. Only customer and worker are allowed.');
      }
    }
    if (!initialRoles.contains(initialActiveRole)) {
      throw const ValidationException('Active role must be one of the selected roles.');
    }

    // 2. Create the Firebase Authentication account
    UserCredential credential;
    try {
      credential = await _authService.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        throw const AuthException(
          'An account with this email address already exists. Please sign in or use profile recovery.',
          code: 'email-already-in-use',
        );
      }
      throw AuthException(e.message ?? 'Registration failed: ${e.code}', code: e.code);
    }

    final user = credential.user;
    if (user == null) {
      throw const AuthException('Registration failed: no user returned.');
    }

    // Update display name in Firebase Auth
    try {
      await user.updateDisplayName(fullName);
    } catch (_) {}

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

    // 3. Create, persist, and verify the corresponding Firestore user document
    try {
      await _firestoreService.setDocument(
        _firestoreService.users,
        user.uid,
        userProfile.toMap(),
      );

      // Verify that the required account data was successfully saved
      final verifyDoc = await _firestoreService.getDocument(_firestoreService.users, user.uid);
      if (!verifyDoc.exists || verifyDoc.data() == null) {
        throw const DatabaseException('Verification failed: User profile document was not created.');
      }
    } catch (e) {
      // Do not silently delete the created Auth account.
      // Sign out cleanly and provide a recoverable state.
      try {
        await _authService.signOut();
      } catch (_) {}
      throw PartialRegistrationException(
        'Account was created, but saving your user profile failed ($e). Please sign in to complete profile setup.',
        details: user.uid,
      );
    }

    // 4. Explicitly sign out the newly created Firebase Authentication session
    // (Firebase createUserWithEmailAndPassword automatically signs in the user)
    await _authService.signOut();

    return userProfile;
  }

  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    // 1. Authenticate using Firebase Authentication
    final credential = await _authService.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = credential.user;
    if (user == null) {
      throw const AuthException('Sign in failed: no user returned.');
    }

    // 2. Retrieve the authenticated user's Firestore profile using their UID
    final profile = await getUserProfile(user.uid);

    // 3. Verify that the profile exists
    if (profile == null) {
      await _authService.signOut();
      throw const ProfileNotFoundException(
        'Account profile document not found. Please contact support or re-register.',
      );
    }

    // 4. Verify that the account is active
    if (profile.accountStatus != 'active') {
      await _authService.signOut();
      throw AccountSuspendedException(
        'Your account is currently ${profile.accountStatus}. Please contact support.',
      );
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

