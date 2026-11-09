import 'dart:async';
import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../core/exceptions/app_exception.dart';
import '../models/user_model.dart';
import '../models/worker_model.dart';
import '../repositories/auth_repository.dart';
import '../repositories/worker_repository.dart';

enum AuthStatus { uninitialized, authenticated, unauthenticated, loading }

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;
  final WorkerRepository _workerRepository;

  AuthStatus _status = AuthStatus.uninitialized;
  UserModel? _currentUser;
  WorkerModel? _workerProfile;
  String? _errorMessage;
  bool _isLoading = false;
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
    final targetUid = uid ?? _currentUser?.uid;
    if (targetUid == null) return;

    try {
      _currentUser = await _authRepository.getUserProfile(targetUid);
      if (_currentUser != null) {
        if (_currentUser!.isWorker) {
          _workerProfile = await _workerRepository.getWorkerProfile(targetUid);
        }
        _status = AuthStatus.authenticated;
      } else {
        _status = AuthStatus.unauthenticated;
      }
    } catch (e) {
      debugPrint('Error refreshing user profile: $e');
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
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
        _workerProfile = await _workerRepository.getWorkerProfile(_currentUser!.uid);
      }
      _status = AuthStatus.authenticated;
      _setLoading(false);
      return true;
    } on AppException catch (e) {
      _setError(e.message);
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('Sign in failed: $e');
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

    try {
      _currentUser = await _authRepository.registerWithEmailAndPassword(
        fullName: fullName,
        email: email,
        password: password,
        initialRoles: initialRoles,
        initialActiveRole: initialActiveRole,
      );
      _status = AuthStatus.authenticated;
      _setLoading(false);
      return true;
    } on AppException catch (e) {
      _setError(e.message);
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('Registration failed: $e');
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
