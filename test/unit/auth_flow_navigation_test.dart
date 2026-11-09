import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter_test/flutter_test.dart';
import 'package:skill_link/core/constants/app_constants.dart';
import 'package:skill_link/core/exceptions/app_exception.dart';
import 'package:skill_link/core/routing/route_names.dart';
import 'package:skill_link/models/user_model.dart';
import 'package:skill_link/models/worker_model.dart';
import 'package:skill_link/providers/auth_provider.dart';
import 'package:skill_link/repositories/auth_repository.dart';
import 'package:skill_link/repositories/worker_repository.dart';

// In-Memory Test Auth Repository that completely isolates from native Firebase channels
class FakeAuthRepository implements AuthRepository {
  UserModel? mockUser;
  bool wasSignedOutAfterRegistration = false;
  bool failNextNetworkOperation = false;
  bool returnNullProfile = false;

  final StreamController<User?> _authController = StreamController<User?>.broadcast();

  @override
  Stream<User?> get authStateChanges => _authController.stream;

  @override
  User? get currentFirebaseUser => null;

  @override
  Future<UserModel> registerWithEmailAndPassword({
    required String fullName,
    required String email,
    required String password,
    required List<String> initialRoles,
    required String initialActiveRole,
  }) async {
    final now = DateTime.now();
    final profile = UserModel(
      uid: 'registered_uid_123',
      fullName: fullName,
      email: email,
      activeRole: initialActiveRole,
      roles: initialRoles,
      accountStatus: 'active',
      createdAt: now,
      updatedAt: now,
    );
    mockUser = profile;
    // Explicitly sign out newly created session
    wasSignedOutAfterRegistration = true;
    _authController.add(null);
    return profile;
  }

  @override
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    if (failNextNetworkOperation) {
      throw const DatabaseException('Network timeout connecting to Firestore.');
    }
    if (returnNullProfile || mockUser == null) {
      throw const ProfileNotFoundException('Account profile document not found.');
    }
    if (mockUser!.accountStatus != 'active') {
      throw AccountSuspendedException('Account is ${mockUser!.accountStatus}.');
    }
    return mockUser!;
  }

  @override
  Future<UserModel?> getUserProfile(String uid) async {
    if (failNextNetworkOperation) {
      throw const DatabaseException('Simulated Firestore network timeout.');
    }
    if (returnNullProfile) return null;
    return mockUser;
  }

  @override
  Future<void> switchActiveRole(String uid, String newRole) async {
    if (mockUser != null) {
      mockUser = mockUser!.copyWith(activeRole: newRole);
    }
  }

  @override
  Future<UserModel> addRole({required String uid, required String newRole}) async {
    final roles = List<String>.from(mockUser?.roles ?? [])..add(newRole);
    mockUser = mockUser!.copyWith(roles: roles, activeRole: newRole);
    return mockUser!;
  }

  @override
  Future<void> updateProfile({required String uid, String? fullName, String? phone, String? photoUrl}) async {}

  @override
  Future<void> sendPasswordReset(String email) async {}

  @override
  Future<void> signOut() async {
    mockUser = null;
    _authController.add(null);
  }
}

// In-Memory Test Worker Repository that completely isolates from native Firebase channels
class FakeWorkerRepository implements WorkerRepository {
  WorkerModel? mockWorker;

  @override
  Future<WorkerModel?> getWorkerProfile(String uid) async {
    return mockWorker;
  }

  @override
  Future<void> saveWorkerProfile(WorkerModel worker) async {
    mockWorker = worker;
  }

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
  group('Authentication Flow & Navigation Route Guard Tests', () {
    late FakeAuthRepository fakeAuth;
    late FakeWorkerRepository fakeWorker;
    late AuthProvider authProvider;

    setUp(() {
      fakeAuth = FakeAuthRepository();
      fakeWorker = FakeWorkerRepository();
      authProvider = AuthProvider(
        authRepository: fakeAuth,
        workerRepository: fakeWorker,
      );
    });

    test('1 & 2: Successful registration signs out the session and leaves unauthenticated', () async {
      final success = await authProvider.register(
        fullName: 'New User',
        email: 'newuser@example.com',
        password: 'Password123!',
        initialRoles: [AppConstants.roleCustomer],
        initialActiveRole: AppConstants.roleCustomer,
      );

      expect(success, isTrue);
      expect(fakeAuth.wasSignedOutAfterRegistration, isTrue);
      expect(authProvider.currentUser, isNull);
      expect(authProvider.isAuthenticated, isFalse);
      expect(authProvider.status, AuthStatus.unauthenticated);
    });

    test('5: Login with Customer role opens Customer Dashboard', () async {
      final now = DateTime.now();
      fakeAuth.mockUser = UserModel(
        uid: 'cust_123',
        fullName: 'Customer Only',
        email: 'customer@example.com',
        activeRole: AppConstants.roleCustomer,
        roles: [AppConstants.roleCustomer],
        accountStatus: 'active',
        createdAt: now,
        updatedAt: now,
      );

      final loggedIn = await authProvider.signIn(
        email: 'customer@example.com',
        password: 'Password123!',
      );

      expect(loggedIn, isTrue);
      expect(authProvider.currentUser?.isCustomerOnly, isTrue);
      final route = authProvider.determineInitialRoute();
      expect(route, equals(RouteNames.customerDashboard));
    });

    test('6: Login with Worker role opens Worker Dashboard when onboarded', () async {
      final now = DateTime.now();
      fakeAuth.mockUser = UserModel(
        uid: 'worker_123',
        fullName: 'Worker Only',
        email: 'worker@example.com',
        activeRole: AppConstants.roleWorker,
        roles: [AppConstants.roleWorker],
        accountStatus: 'active',
        createdAt: now,
        updatedAt: now,
      );
      fakeWorker.mockWorker = WorkerModel(
        uid: 'worker_123',
        fullName: 'Worker Only',
        headline: 'Electrician Pro',
        description: 'Certified specialist',
        skills: ['Wiring', 'Panels'],
        category: 'Electrician',
        experienceYears: 5,
        city: 'Mumbai',
        state: 'Maharashtra',
        locality: 'Andheri',
        rate: 500,
        availability: 'Immediate',
        profileStatus: 'completed',
        createdAt: now,
        updatedAt: now,
      );

      final loggedIn = await authProvider.signIn(
        email: 'worker@example.com',
        password: 'Password123!',
      );

      expect(loggedIn, isTrue);
      expect(authProvider.isWorkerOnboarded, isTrue);
      final route = authProvider.determineInitialRoute();
      expect(route, equals(RouteNames.workerDashboard));
    });

    test('8: Login with Worker role redirects to onboarding if profile is incomplete', () async {
      final now = DateTime.now();
      fakeAuth.mockUser = UserModel(
        uid: 'worker_incomplete',
        fullName: 'Worker Incomplete',
        email: 'worker.inc@example.com',
        activeRole: AppConstants.roleWorker,
        roles: [AppConstants.roleWorker],
        accountStatus: 'active',
        createdAt: now,
        updatedAt: now,
      );
      fakeWorker.mockWorker = null;

      final loggedIn = await authProvider.signIn(
        email: 'worker.inc@example.com',
        password: 'Password123!',
      );

      expect(loggedIn, isTrue);
      expect(authProvider.isWorkerOnboarded, isFalse);
      final route = authProvider.determineInitialRoute();
      expect(route, equals(RouteNames.workerOnboarding));
    });

    test('7a: Login with both roles uses saved active portal (Customer)', () async {
      final now = DateTime.now();
      fakeAuth.mockUser = UserModel(
        uid: 'dual_user_1',
        fullName: 'Dual User',
        email: 'dual@example.com',
        activeRole: AppConstants.roleCustomer,
        roles: [AppConstants.roleCustomer, AppConstants.roleWorker],
        accountStatus: 'active',
        createdAt: now,
        updatedAt: now,
      );

      await authProvider.signIn(email: 'dual@example.com', password: 'pass');
      expect(authProvider.currentUser?.hasBothRoles, isTrue);
      final route = authProvider.determineInitialRoute();
      expect(route, equals(RouteNames.customerDashboard));
    });

    test('7b: Login with both roles uses saved active portal (Worker - Onboarded)', () async {
      final now = DateTime.now();
      fakeAuth.mockUser = UserModel(
        uid: 'dual_user_2',
        fullName: 'Dual User 2',
        email: 'dual2@example.com',
        activeRole: AppConstants.roleWorker,
        roles: [AppConstants.roleCustomer, AppConstants.roleWorker],
        accountStatus: 'active',
        createdAt: now,
        updatedAt: now,
      );
      fakeWorker.mockWorker = WorkerModel(
        uid: 'dual_user_2',
        fullName: 'Dual User 2',
        headline: 'Plumber',
        description: 'Plumber bio',
        skills: ['Plumbing'],
        category: 'Plumber',
        experienceYears: 4,
        city: 'Delhi',
        state: 'Delhi',
        locality: 'Dwarka',
        rate: 400,
        availability: 'Daily',
        profileStatus: 'completed',
        createdAt: now,
        updatedAt: now,
      );

      await authProvider.signIn(email: 'dual2@example.com', password: 'pass');
      final route = authProvider.determineInitialRoute();
      expect(route, equals(RouteNames.workerDashboard));
    });

    test('7c: Login with both roles without a valid active portal defaults to Portal Selection', () async {
      final now = DateTime.now();
      fakeAuth.mockUser = UserModel(
        uid: 'dual_user_3',
        fullName: 'Dual User 3',
        email: 'dual3@example.com',
        activeRole: '', // No valid active portal stored
        roles: [AppConstants.roleCustomer, AppConstants.roleWorker],
        accountStatus: 'active',
        createdAt: now,
        updatedAt: now,
      );

      await authProvider.signIn(email: 'dual3@example.com', password: 'pass');
      final route = authProvider.determineInitialRoute();
      expect(route, equals(RouteNames.portalSelect));
    });

    test('9: Missing profile is handled safely with ProfileNotFoundException', () async {
      fakeAuth.returnNullProfile = true;

      final success = await authProvider.signIn(
        email: 'missing@example.com',
        password: 'Password123!',
      );

      expect(success, isFalse);
      expect(authProvider.currentUser, isNull);
      expect(authProvider.errorMessage, contains('not found'));
    });

    test('10: Firestore network failure is set to networkError, not treated as unauthenticated or incomplete', () async {
      final now = DateTime.now();
      fakeAuth.mockUser = UserModel(
        uid: 'user_active',
        fullName: 'Active User',
        email: 'active@example.com',
        activeRole: AppConstants.roleCustomer,
        roles: [AppConstants.roleCustomer],
        createdAt: now,
        updatedAt: now,
      );

      fakeAuth.failNextNetworkOperation = true;
      await authProvider.refreshUserProfile('user_active');

      expect(authProvider.status, equals(AuthStatus.networkError));
      expect(authProvider.errorMessage, contains('Network connection error'));
    });

    test('11: Portal switching works without logging out', () async {
      final now = DateTime.now();
      fakeAuth.mockUser = UserModel(
        uid: 'dual_switch',
        fullName: 'Dual Switch User',
        email: 'switch@example.com',
        activeRole: AppConstants.roleCustomer,
        roles: [AppConstants.roleCustomer, AppConstants.roleWorker],
        accountStatus: 'active',
        createdAt: now,
        updatedAt: now,
      );

      await authProvider.signIn(email: 'switch@example.com', password: 'pass');
      expect(authProvider.activeRole, equals(AppConstants.roleCustomer));

      final switchResult = await authProvider.switchPortal(AppConstants.roleWorker);
      expect(switchResult, anyOf('success', 'needs_worker_onboarding'));
      expect(authProvider.activeRole, equals(AppConstants.roleWorker));
      expect(authProvider.currentUser, isNotNull);
      expect(authProvider.isAuthenticated, isTrue);
    });

    test('12: Logout clears session and prevents protected access', () async {
      final now = DateTime.now();
      fakeAuth.mockUser = UserModel(
        uid: 'logout_test',
        fullName: 'Logout User',
        email: 'logout@example.com',
        activeRole: AppConstants.roleCustomer,
        roles: [AppConstants.roleCustomer],
        accountStatus: 'active',
        createdAt: now,
        updatedAt: now,
      );

      await authProvider.signIn(email: 'logout@example.com', password: 'pass');
      expect(authProvider.isAuthenticated, isTrue);

      await authProvider.signOut();
      expect(authProvider.currentUser, isNull);
      expect(authProvider.isAuthenticated, isFalse);
      expect(authProvider.status, equals(AuthStatus.unauthenticated));
    });

    test('13a: getFindWorkersDestination returns Login with redirect for logged-out visitors', () {
      expect(authProvider.isAuthenticated, isFalse);
      final dest = authProvider.getFindWorkersDestination();
      expect(dest, equals('${RouteNames.login}?redirect=${Uri.encodeComponent(RouteNames.customerFindWorkers)}'));
    });

    test('13b: getFindWorkersDestination returns Worker Dashboard for worker-only account', () async {
      final now = DateTime.now();
      fakeAuth.mockUser = UserModel(
        uid: 'worker_only_dest',
        fullName: 'Worker Only',
        email: 'worker.dest@example.com',
        activeRole: AppConstants.roleWorker,
        roles: [AppConstants.roleWorker],
        accountStatus: 'active',
        createdAt: now,
        updatedAt: now,
      );
      await authProvider.signIn(email: 'worker.dest@example.com', password: 'pass');
      expect(authProvider.hasCustomerRole, isFalse);
      expect(authProvider.hasWorkerRole, isTrue);

      final dest = authProvider.getFindWorkersDestination();
      expect(dest, equals(RouteNames.workerDashboard));
    });

    test('13c: getFindWorkersDestination returns customerFindWorkers for customer account', () async {
      final now = DateTime.now();
      fakeAuth.mockUser = UserModel(
        uid: 'cust_dest',
        fullName: 'Customer Only',
        email: 'cust.dest@example.com',
        activeRole: AppConstants.roleCustomer,
        roles: [AppConstants.roleCustomer],
        accountStatus: 'active',
        createdAt: now,
        updatedAt: now,
      );
      await authProvider.signIn(email: 'cust.dest@example.com', password: 'pass');
      expect(authProvider.hasCustomerRole, isTrue);

      final dest = authProvider.getFindWorkersDestination();
      expect(dest, equals(RouteNames.customerFindWorkers));
    });

    test('14: determineInitialRoute honors preserved redirect parameter for authorized role', () async {
      final now = DateTime.now();
      fakeAuth.mockUser = UserModel(
        uid: 'cust_redirect',
        fullName: 'Customer Redirect',
        email: 'cust.redir@example.com',
        activeRole: AppConstants.roleCustomer,
        roles: [AppConstants.roleCustomer],
        accountStatus: 'active',
        createdAt: now,
        updatedAt: now,
      );
      await authProvider.signIn(email: 'cust.redir@example.com', password: 'pass');

      final route = authProvider.determineInitialRoute(redirectUrl: RouteNames.customerFindWorkers);
      expect(route, equals(RouteNames.customerFindWorkers));
    });

    test('15: determineInitialRoute denies unauthorized redirect and falls back to user role dashboard', () async {
      final now = DateTime.now();
      fakeAuth.mockUser = UserModel(
        uid: 'worker_redirect',
        fullName: 'Worker Redirect',
        email: 'worker.redir@example.com',
        activeRole: AppConstants.roleWorker,
        roles: [AppConstants.roleWorker],
        accountStatus: 'active',
        createdAt: now,
        updatedAt: now,
      );
      fakeWorker.mockWorker = WorkerModel(
        uid: 'worker_redirect',
        fullName: 'Worker Redirect',
        headline: 'Plumber',
        description: 'Plumber bio',
        skills: ['Plumbing'],
        category: 'Plumber',
        experienceYears: 4,
        city: 'Delhi',
        state: 'Delhi',
        locality: 'Dwarka',
        rate: 400,
        availability: 'Daily',
        profileStatus: 'completed',
        createdAt: now,
        updatedAt: now,
      );
      await authProvider.signIn(email: 'worker.redir@example.com', password: 'pass');

      // Worker attempting to access customer-only route via redirectUrl
      final route = authProvider.determineInitialRoute(redirectUrl: RouteNames.customerFindWorkers);
      expect(route, equals(RouteNames.workerDashboard));
    });

    test('16: Suspended account returns authError route and is blocked', () async {
      final now = DateTime.now();
      fakeAuth.mockUser = UserModel(
        uid: 'suspended_user',
        fullName: 'Suspended User',
        email: 'suspended@example.com',
        activeRole: AppConstants.roleCustomer,
        roles: [AppConstants.roleCustomer],
        accountStatus: 'suspended',
        createdAt: now,
        updatedAt: now,
      );

      await authProvider.signIn(email: 'suspended@example.com', password: 'pass');
      final route = authProvider.determineInitialRoute();
      expect(route, equals(RouteNames.authError));
    });
  });
}
