import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter_test/flutter_test.dart';
import 'package:skill_link/core/constants/app_constants.dart';
import 'package:skill_link/core/routing/app_router.dart';
import 'package:skill_link/core/routing/route_names.dart';
import 'package:skill_link/models/user_model.dart';
import 'package:skill_link/models/worker_model.dart';
import 'package:skill_link/providers/auth_provider.dart';
import 'package:skill_link/repositories/auth_repository.dart';
import 'package:skill_link/repositories/worker_repository.dart';

class _FakeAuthRepo implements AuthRepository {
  UserModel? mockUser;
  final StreamController<User?> _controller = StreamController<User?>.broadcast();

  void emitLoggedOut() {
    _controller.add(null);
  }

  @override
  Stream<User?> get authStateChanges => _controller.stream;

  @override
  User? get currentFirebaseUser => null;

  @override
  Future<UserModel> registerWithEmailAndPassword({
    required String fullName,
    required String email,
    required String password,
    required List<String> initialRoles,
    required String initialActiveRole,
  }) async => throw UnimplementedError();

  @override
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    if (mockUser != null) return mockUser!;
    throw UnimplementedError();
  }

  @override
  Future<UserModel?> getUserProfile(String uid) async => mockUser;

  @override
  Future<void> switchActiveRole(String uid, String newRole) async {}

  @override
  Future<UserModel> addRole({required String uid, required String newRole}) async => throw UnimplementedError();

  @override
  Future<void> updateProfile({required String uid, String? fullName, String? phone, String? photoUrl}) async {}

  @override
  Future<void> sendPasswordReset(String email) async {}

  @override
  Future<void> signOut() async {
    mockUser = null;
    _controller.add(null);
  }
}

class _FakeWorkerRepo implements WorkerRepository {
  WorkerModel? mockWorker;

  @override
  Future<WorkerModel?> getWorkerProfile(String uid) async => mockWorker;

  @override
  Future<void> saveWorkerProfile(WorkerModel worker) async {}

  @override
  Future<List<WorkerModel>> fetchWorkers({
    String? category,
    String? searchQuery,
    String? city,
    double? maxRate,
    double? minRating,
    String sortBy = 'rating_desc',
    int limit = 20,
  }) async => [];

  @override
  Stream<List<WorkerModel>> streamFeaturedWorkers({int limit = 6}) => const Stream.empty();
}

void main() {
  group('AppRouter Centralized Route Guard Unit Tests', () {
    late _FakeAuthRepo fakeAuth;
    late _FakeWorkerRepo fakeWorker;
    late AuthProvider authProvider;

    setUp(() async {
      fakeAuth = _FakeAuthRepo();
      fakeWorker = _FakeWorkerRepo();
      authProvider = AuthProvider(
        authRepository: fakeAuth,
        workerRepository: fakeWorker,
      );
      fakeAuth.emitLoggedOut();
      await Future.delayed(Duration.zero);
    });

    test('0. While auth is uninitialized or loading, protected routes redirect to splash', () {
      final uninitProvider = AuthProvider(
        authRepository: _FakeAuthRepo(),
        workerRepository: _FakeWorkerRepo(),
      );
      expect(uninitProvider.status, equals(AuthStatus.uninitialized));

      expect(
        AppRouter.evaluateRouteProtection(
          authProvider: uninitProvider,
          location: RouteNames.customerDashboard,
        ),
        equals(RouteNames.splash),
      );
      expect(
        AppRouter.evaluateRouteProtection(
          authProvider: uninitProvider,
          location: RouteNames.login,
        ),
        equals(RouteNames.splash),
      );
      expect(
        AppRouter.evaluateRouteProtection(
          authProvider: uninitProvider,
          location: RouteNames.landing,
        ),
        isNull,
      );
    });

    test('1. Unauthenticated users are redirected to Login from all protected routes', () {
      expect(authProvider.isAuthenticated, isFalse);

      final protectedRoutes = [
        RouteNames.customerDashboard,
        RouteNames.customerFindWorkers,
        RouteNames.customerPostJob,
        RouteNames.customerJobs,
        RouteNames.customerSavedWorkers,
        RouteNames.workerDashboard,
        RouteNames.workerBrowseJobs,
        RouteNames.workerApplications,
        RouteNames.workerProfile,
        RouteNames.notifications,
        RouteNames.settings,
      ];

      for (final route in protectedRoutes) {
        final redirect = AppRouter.evaluateRouteProtection(
          authProvider: authProvider,
          location: route,
        );
        expect(
          redirect,
          equals('${RouteNames.login}?redirect=${Uri.encodeComponent(route)}'),
          reason: 'Unauthenticated route $route must redirect to login with redirect parameter',
        );
      }
    });

    test('2. Public routes are accessible to unauthenticated visitors without redirection', () {
      expect(authProvider.isAuthenticated, isFalse);

      final publicRoutes = [
        RouteNames.landing,
        RouteNames.login,
        RouteNames.register,
        RouteNames.forgotPassword,
        RouteNames.splash,
      ];

      for (final route in publicRoutes) {
        final redirect = AppRouter.evaluateRouteProtection(
          authProvider: authProvider,
          location: route,
        );
        expect(redirect, isNull, reason: 'Public route $route must not be redirected');
      }
    });

    test('3. Authenticated customer can access all customer routes and is blocked from worker routes', () async {
      final now = DateTime.now();
      fakeAuth.mockUser = UserModel(
        uid: 'cust_guard_test',
        fullName: 'Customer Guard',
        email: 'customer@guard.com',
        activeRole: AppConstants.roleCustomer,
        roles: [AppConstants.roleCustomer],
        accountStatus: 'active',
        createdAt: now,
        updatedAt: now,
      );
      await authProvider.signIn(email: 'customer@guard.com', password: 'pass');
      expect(authProvider.isAuthenticated, isTrue);

      // Customer routes allowed
      expect(
        AppRouter.evaluateRouteProtection(
          authProvider: authProvider,
          location: RouteNames.customerDashboard,
        ),
        isNull,
      );
      expect(
        AppRouter.evaluateRouteProtection(
          authProvider: authProvider,
          location: RouteNames.customerFindWorkers,
        ),
        isNull,
      );

      // Worker routes redirected to customer dashboard
      expect(
        AppRouter.evaluateRouteProtection(
          authProvider: authProvider,
          location: RouteNames.workerDashboard,
        ),
        equals(RouteNames.customerDashboard),
      );
      expect(
        AppRouter.evaluateRouteProtection(
          authProvider: authProvider,
          location: RouteNames.workerBrowseJobs,
        ),
        equals(RouteNames.customerDashboard),
      );
    });

    test('4. Authenticated worker can access worker routes and is blocked from customer routes', () async {
      final now = DateTime.now();
      fakeAuth.mockUser = UserModel(
        uid: 'worker_guard_test',
        fullName: 'Worker Guard',
        email: 'worker@guard.com',
        activeRole: AppConstants.roleWorker,
        roles: [AppConstants.roleWorker],
        accountStatus: 'active',
        createdAt: now,
        updatedAt: now,
      );
      fakeWorker.mockWorker = WorkerModel(
        uid: 'worker_guard_test',
        fullName: 'Worker Guard',
        headline: 'Electrician',
        description: 'Certified Electrician',
        skills: ['Electrical'],
        category: 'Electrician',
        experienceYears: 6,
        city: 'Pune',
        state: 'Maharashtra',
        locality: 'Kothrud',
        rate: 550,
        availability: 'Immediate',
        profileStatus: 'completed',
        createdAt: now,
        updatedAt: now,
      );
      await authProvider.signIn(email: 'worker@guard.com', password: 'pass');
      expect(authProvider.isAuthenticated, isTrue);
      expect(authProvider.isWorkerOnboarded, isTrue);

      // Worker routes allowed
      expect(
        AppRouter.evaluateRouteProtection(
          authProvider: authProvider,
          location: RouteNames.workerDashboard,
        ),
        isNull,
      );
      expect(
        AppRouter.evaluateRouteProtection(
          authProvider: authProvider,
          location: RouteNames.workerBrowseJobs,
        ),
        isNull,
      );

      // Customer routes redirected to worker dashboard
      expect(
        AppRouter.evaluateRouteProtection(
          authProvider: authProvider,
          location: RouteNames.customerDashboard,
        ),
        equals(RouteNames.workerDashboard),
      );
      expect(
        AppRouter.evaluateRouteProtection(
          authProvider: authProvider,
          location: RouteNames.customerFindWorkers,
        ),
        equals(RouteNames.workerDashboard),
      );
    });

    test('5. Authenticated dual-role user can access both customer and worker routes', () async {
      final now = DateTime.now();
      fakeAuth.mockUser = UserModel(
        uid: 'dual_guard_test',
        fullName: 'Dual Guard',
        email: 'dual@guard.com',
        activeRole: AppConstants.roleCustomer,
        roles: [AppConstants.roleCustomer, AppConstants.roleWorker],
        accountStatus: 'active',
        createdAt: now,
        updatedAt: now,
      );
      fakeWorker.mockWorker = WorkerModel(
        uid: 'dual_guard_test',
        fullName: 'Dual Guard',
        headline: 'Painter',
        description: 'Pro painter',
        skills: ['Painting'],
        category: 'Painter',
        experienceYears: 3,
        city: 'Mumbai',
        state: 'Maharashtra',
        locality: 'Bandra',
        rate: 450,
        availability: 'Full-time',
        profileStatus: 'completed',
        createdAt: now,
        updatedAt: now,
      );
      await authProvider.signIn(email: 'dual@guard.com', password: 'pass');
      expect(authProvider.currentUser?.hasBothRoles, isTrue);

      // Both customer and worker routes are permitted
      expect(
        AppRouter.evaluateRouteProtection(
          authProvider: authProvider,
          location: RouteNames.customerDashboard,
        ),
        isNull,
      );
      expect(
        AppRouter.evaluateRouteProtection(
          authProvider: authProvider,
          location: RouteNames.customerFindWorkers,
        ),
        isNull,
      );
      expect(
        AppRouter.evaluateRouteProtection(
          authProvider: authProvider,
          location: RouteNames.workerDashboard,
        ),
        isNull,
      );
      expect(
        AppRouter.evaluateRouteProtection(
          authProvider: authProvider,
          location: RouteNames.workerBrowseJobs,
        ),
        isNull,
      );
    });

    test('6. Incomplete worker profile redirects to onboarding from protected worker routes', () async {
      final now = DateTime.now();
      fakeAuth.mockUser = UserModel(
        uid: 'incomplete_worker',
        fullName: 'Incomplete Worker',
        email: 'incomplete@guard.com',
        activeRole: AppConstants.roleWorker,
        roles: [AppConstants.roleWorker],
        accountStatus: 'active',
        createdAt: now,
        updatedAt: now,
      );
      fakeWorker.mockWorker = null; // No completed worker profile
      await authProvider.signIn(email: 'incomplete@guard.com', password: 'pass');
      expect(authProvider.isWorkerOnboarded, isFalse);

      expect(
        AppRouter.evaluateRouteProtection(
          authProvider: authProvider,
          location: RouteNames.workerDashboard,
        ),
        equals(RouteNames.workerOnboarding),
      );
      expect(
        AppRouter.evaluateRouteProtection(
          authProvider: authProvider,
          location: RouteNames.workerBrowseJobs,
        ),
        equals(RouteNames.workerOnboarding),
      );
      expect(
        AppRouter.evaluateRouteProtection(
          authProvider: authProvider,
          location: RouteNames.workerOnboarding,
        ),
        isNull,
      );
    });

    test('7. Authenticated user visiting auth routes is redirected to their dashboard', () async {
      final now = DateTime.now();
      fakeAuth.mockUser = UserModel(
        uid: 'cust_auth_route',
        fullName: 'Customer Nav',
        email: 'cust.nav@guard.com',
        activeRole: AppConstants.roleCustomer,
        roles: [AppConstants.roleCustomer],
        accountStatus: 'active',
        createdAt: now,
        updatedAt: now,
      );
      await authProvider.signIn(email: 'cust.nav@guard.com', password: 'pass');

      // Visiting /login or /register while authenticated redirects to Customer Dashboard
      expect(
        AppRouter.evaluateRouteProtection(
          authProvider: authProvider,
          location: RouteNames.login,
        ),
        equals(RouteNames.customerDashboard),
      );
      expect(
        AppRouter.evaluateRouteProtection(
          authProvider: authProvider,
          location: RouteNames.register,
        ),
        equals(RouteNames.customerDashboard),
      );
    });

    test('8. Authenticated user visiting /login with authorized redirect honors the redirect', () async {
      final now = DateTime.now();
      fakeAuth.mockUser = UserModel(
        uid: 'cust_param_test',
        fullName: 'Customer Param',
        email: 'cust.param@guard.com',
        activeRole: AppConstants.roleCustomer,
        roles: [AppConstants.roleCustomer],
        accountStatus: 'active',
        createdAt: now,
        updatedAt: now,
      );
      await authProvider.signIn(email: 'cust.param@guard.com', password: 'pass');

      final redirect = AppRouter.evaluateRouteProtection(
        authProvider: authProvider,
        location: RouteNames.login,
        redirectParam: RouteNames.customerFindWorkers,
      );
      expect(redirect, equals(RouteNames.customerFindWorkers));
    });

    test('9. Authenticated worker visiting /login with customer-only redirect is redirected to worker dashboard', () async {
      final now = DateTime.now();
      fakeAuth.mockUser = UserModel(
        uid: 'worker_param_test',
        fullName: 'Worker Param',
        email: 'worker.param@guard.com',
        activeRole: AppConstants.roleWorker,
        roles: [AppConstants.roleWorker],
        accountStatus: 'active',
        createdAt: now,
        updatedAt: now,
      );
      fakeWorker.mockWorker = WorkerModel(
        uid: 'worker_param_test',
        fullName: 'Worker Param',
        headline: 'Carpenter',
        description: 'Pro Carpenter',
        skills: ['Woodwork'],
        category: 'Carpenter',
        experienceYears: 4,
        city: 'Mumbai',
        state: 'Maharashtra',
        locality: 'Dadar',
        rate: 500,
        availability: 'Immediate',
        profileStatus: 'completed',
        createdAt: now,
        updatedAt: now,
      );
      await authProvider.signIn(email: 'worker.param@guard.com', password: 'pass');

      // Worker tried to preserve customerFindWorkers
      final redirect = AppRouter.evaluateRouteProtection(
        authProvider: authProvider,
        location: RouteNames.login,
        redirectParam: RouteNames.customerFindWorkers,
      );
      expect(redirect, equals(RouteNames.workerDashboard));
    });
  });
}
