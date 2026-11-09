import 'dart:async';
import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../core/exceptions/app_exception.dart';
import '../core/routing/route_names.dart';
import '../models/user_model.dart';
import '../models/worker_model.dart';
import '../repositories/auth_repository.dart';
import '../repositories/worker_repository.dart';

enum AuthStatus {
  uninitialized,
  authenticated,
  unauthenticated,
  loading,
  networkError,
  profileMissing,
  accountSuspended,
  permissionDenied,
}

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;
  final WorkerRepository _workerRepository;

  AuthStatus _status = AuthStatus.uninitialized;
  UserModel? _currentUser;
  WorkerModel? _workerProfile;
  String? _errorMessage;
  bool _isLoading = false;
  bool _isRegistering = false;
  StreamSubscription? _authSubscription;

  AuthProvider({
    AuthRepository? authRepository,
    WorkerRepository? workerRepository,
  })  : _authRepository = authRepository ?? AuthRepository(),
        _workerRepository = workerRepository ?? WorkerRepository() {
    _init();
  }

  AuthStatus get status => _status;
  UserModel? get currentUser => _currentUser;
  WorkerModel? get workerProfile => _workerProfile;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _status == AuthStatus.authenticated && _currentUser != null;

  String get activeRole => _currentUser?.activeRole ?? AppConstants.roleCustomer;
  bool get isCustomerActive => activeRole == AppConstants.roleCustomer;
  bool get isWorkerActive => activeRole == AppConstants.roleWorker;

  bool get hasCustomerRole => _currentUser?.isCustomer ?? false;
  bool get hasWorkerRole => _currentUser?.isWorker ?? false;
  bool get hasBothRoles => _currentUser?.hasBothRoles ?? false;

  bool get isWorkerOnboarded =>
      _workerProfile != null && _workerProfile!.profileStatus == 'completed';

  void _init() {
    _authSubscription = _authRepository.authStateChanges.listen((firebaseUser) async {
      if (_isRegistering) {
        // While user is registering, do not process authStateChanges into an authenticated session
        return;
      }
      if (firebaseUser == null) {
        _currentUser = null;
        _workerProfile = null;
        _status = AuthStatus.unauthenticated;
        notifyListeners();
      } else {
        await refreshUserProfile(firebaseUser.uid);
      }
    });
  }

  Future<void> refreshUserProfile([String? uid]) async {
    final targetUid = uid ?? _currentUser?.uid ?? _authRepository.currentFirebaseUser?.uid;
    if (targetUid == null) {
      _currentUser = null;
      _workerProfile = null;
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return;
    }

    try {
      final profile = await _authRepository.getUserProfile(targetUid);
      if (profile == null) {
        // Authenticated in Auth, but user document missing
        _currentUser = null;
        _workerProfile = null;
        _status = AuthStatus.profileMissing;
        _setError('Account profile document was not found.');
      } else if (profile.accountStatus != 'active') {
        _currentUser = profile;
        _status = AuthStatus.accountSuspended;
        _setError('Your account is currently ${profile.accountStatus}.');
      } else {
        _currentUser = profile;
        if (profile.isWorker) {
          try {
            _workerProfile = await _workerRepository.getWorkerProfile(targetUid);
          } catch (_) {}
        }
        _status = AuthStatus.authenticated;
        _clearError();
      }
    } on PermissionException catch (e) {
      debugPrint('Firestore Permission error: $e');
      _currentUser = null;
      _workerProfile = null;
      _status = AuthStatus.permissionDenied;
      _setError('Firestore permission error: Missing or insufficient permissions. Please check security rules in Firebase Console.');
    } on DatabaseException catch (e) {
      if (e.code == 'permission-denied') {
        _currentUser = null;
        _workerProfile = null;
        _status = AuthStatus.permissionDenied;
        _setError('Firestore permission error: Missing or insufficient permissions. Please check security rules in Firebase Console.');
      } else {
        debugPrint('Database or network error: $e');
        _status = AuthStatus.networkError;
        _setError('Network connection error: Unable to load profile. Please check your connection.');
      }
    } catch (e) {
      debugPrint('Unexpected error refreshing profile: $e');
      _status = AuthStatus.networkError;
      _setError('Unable to load user profile: $e');
    }
    notifyListeners();
  }

  Future<void> retryLoadProfile() async {
    _setLoading(true);
    _clearError();
    await refreshUserProfile();
    _setLoading(false);
  }

  /// Centrally determines the appropriate dashboard or screen for an authenticated user.
  String determineInitialRoute({String? redirectUrl}) {
    if (_status == AuthStatus.accountSuspended ||
        _status == AuthStatus.permissionDenied ||
        (_currentUser != null && _currentUser!.accountStatus != 'active')) {
      return RouteNames.authError;
    }
    if (_currentUser == null) return RouteNames.login;

    final user = _currentUser!;
    final hasCustomer = user.roles.contains(AppConstants.roleCustomer);
    final hasWorker = user.roles.contains(AppConstants.roleWorker);

    // If a redirect URL was requested and user is authorized, honor it
    if (redirectUrl != null &&
        redirectUrl.isNotEmpty &&
        redirectUrl != RouteNames.login &&
        redirectUrl != RouteNames.register &&
        redirectUrl != RouteNames.forgotPassword &&
        redirectUrl != RouteNames.splash) {
      if (redirectUrl.startsWith('/customer/') && hasCustomer) {
        return redirectUrl;
      }
      if (redirectUrl.startsWith('/worker/') && hasWorker) {
        if (!isWorkerOnboarded && redirectUrl != RouteNames.workerOnboarding) {
          return RouteNames.workerOnboarding;
        }
        return redirectUrl;
      }
    }

    // 1. Single role: Customer
    if (hasCustomer && !hasWorker) {
      return RouteNames.customerDashboard;
    }

    // 2. Single role: Worker
    if (hasWorker && !hasCustomer) {
      return isWorkerOnboarded
          ? RouteNames.workerDashboard
          : RouteNames.workerOnboarding;
    }

    // 3. Both roles:
    // Use the saved active portal if valid; otherwise display Portal Selection.
    if (hasCustomer && hasWorker) {
      final active = user.activeRole;
      if (active == AppConstants.roleWorker) {
        return isWorkerOnboarded
            ? RouteNames.workerDashboard
            : RouteNames.workerOnboarding;
      } else if (active == AppConstants.roleCustomer) {
        return RouteNames.customerDashboard;
      } else {
        return RouteNames.portalSelect;
      }
    }

    return RouteNames.authError;
  }

  /// Returns the appropriate navigation destination when accessing Find Workers.
  /// - Logged-out visitors -> Login with preserved redirect parameter
  /// - Worker-only accounts -> Worker Dashboard
  /// - Customer accounts -> Find Workers directory
  String getFindWorkersDestination() {
    if (!isAuthenticated) {
      return '${RouteNames.login}?redirect=${Uri.encodeComponent(RouteNames.customerFindWorkers)}';
    }
    if (!hasCustomerRole && hasWorkerRole) {
      return RouteNames.workerDashboard;
    }
    return RouteNames.customerFindWorkers;
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      _currentUser = await _authRepository.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (_currentUser!.isWorker) {
        try {
          _workerProfile = await _workerRepository.getWorkerProfile(_currentUser!.uid);
        } catch (_) {}
      }
      _status = AuthStatus.authenticated;
      _setLoading(false);
      return true;
    } on PermissionException catch (e) {
      _setError('Firestore permission error: Missing or insufficient permissions (${e.message}). Please check security rules in Firebase Console.');
      _status = AuthStatus.permissionDenied;
      _setLoading(false);
      return false;
    } on AccountSuspendedException catch (e) {
      _setError(e.message);
      _status = AuthStatus.accountSuspended;
      _setLoading(false);
      return false;
    } on ProfileNotFoundException catch (e) {
      _setError(e.message);
      _status = AuthStatus.profileMissing;
      _setLoading(false);
      return false;
    } on DatabaseException catch (e) {
      if (e.code == 'permission-denied') {
        _setError('Firestore permission error: Missing or insufficient permissions. Please check security rules in Firebase Console.');
        _status = AuthStatus.permissionDenied;
      } else {
        _setError(e.message);
        _status = AuthStatus.networkError;
      }
      _setLoading(false);
      return false;
    } on AppException catch (e) {
      _setError(e.message);
      _status = AuthStatus.unauthenticated;
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('Sign in failed: $e');
      _status = AuthStatus.unauthenticated;
      _setLoading(false);
      return false;
    }
  }

  Future<bool> register({
    required String fullName,
    required String email,
    required String password,
    required List<String> initialRoles,
    required String initialActiveRole,
  }) async {
    _setLoading(true);
    _clearError();
    _isRegistering = true; // Shield against intermediate authStateChanges

    try {
      await _authRepository.registerWithEmailAndPassword(
        fullName: fullName,
        email: email,
        password: password,
        initialRoles: initialRoles,
        initialActiveRole: initialActiveRole,
      );
      // Explicitly marked unauthenticated because AuthRepository signs out after creating doc
      _currentUser = null;
      _workerProfile = null;
      _status = AuthStatus.unauthenticated;
      _isRegistering = false;
      _setLoading(false);
      return true;
    } on PartialRegistrationException catch (e) {
      _setError(e.message);
      _status = AuthStatus.profileMissing;
      _isRegistering = false;
      _setLoading(false);
      return false;
    } on PermissionException catch (e) {
      _setError('Firestore permission error: Missing or insufficient permissions (${e.message}). Your security rules in Firebase Console must allow authenticated profile creation.');
      _status = AuthStatus.permissionDenied;
      _isRegistering = false;
      _setLoading(false);
      return false;
    } on AppException catch (e) {
      _setError(e.message);
      _isRegistering = false;
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('Registration failed: $e');
      _isRegistering = false;
      _setLoading(false);
      return false;
    }
  }

  /// Switches active portal between 'customer' and 'worker'
  /// Returns:
  /// - 'success' if role switched and profile is ready
  /// - 'needs_worker_onboarding' if user has worker role but profile is incomplete
  /// - 'role_not_enrolled' if user does not have requested role
  Future<String> switchPortal(String targetRole) async {
    if (_currentUser == null) return 'unauthenticated';

    if (!_currentUser!.roles.contains(targetRole)) {
      return 'role_not_enrolled';
    }

    _setLoading(true);
    try {
      await _authRepository.switchActiveRole(_currentUser!.uid, targetRole);
      _currentUser = _currentUser!.copyWith(activeRole: targetRole);

      if (targetRole == AppConstants.roleWorker) {
        _workerProfile = await _workerRepository.getWorkerProfile(_currentUser!.uid);
        _setLoading(false);
        if (_workerProfile == null || _workerProfile!.profileStatus != 'completed') {
          notifyListeners();
          return 'needs_worker_onboarding';
        }
      }

      _setLoading(false);
      notifyListeners();
      return 'success';
    } catch (e) {
      _setError('Failed to switch portal: $e');
      _setLoading(false);
      return 'error';
    }
  }

  /// Adds a new role (e.g. customer enrolling as worker, or worker adding customer role)
  Future<bool> enrollRole(String newRole) async {
    if (_currentUser == null) return false;

    _setLoading(true);
    _clearError();

    try {
      _currentUser = await _authRepository.addRole(
        uid: _currentUser!.uid,
        newRole: newRole,
      );
      if (newRole == AppConstants.roleWorker) {
        _workerProfile = await _workerRepository.getWorkerProfile(_currentUser!.uid);
      }
      _setLoading(false);
      notifyListeners();
      return true;
    } on AppException catch (e) {
      _setError(e.message);
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('Failed to add role: $e');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> sendPasswordReset(String email) async {
    _setLoading(true);
    _clearError();

    try {
      await _authRepository.sendPasswordReset(email);
      _setLoading(false);
      return true;
    } on AppException catch (e) {
      _setError(e.message);
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('Failed to send reset email: $e');
      _setLoading(false);
      return false;
    }
  }

  Future<void> updateProfile({String? fullName, String? phone, String? photoUrl}) async {
    if (_currentUser == null) return;
    _setLoading(true);
    try {
      await _authRepository.updateProfile(
        uid: _currentUser!.uid,
        fullName: fullName,
        phone: phone,
        photoUrl: photoUrl,
      );
      _currentUser = _currentUser!.copyWith(
        fullName: fullName,
        phone: phone,
        photoUrl: photoUrl,
      );
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError('Failed to update profile: $e');
      _setLoading(false);
    }
  }

  void setWorkerProfile(WorkerModel profile) {
    _workerProfile = profile;
    notifyListeners();
  }

  Future<void> signOut() async {
    await _authRepository.signOut();
    _currentUser = null;
    _workerProfile = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}

