import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:skill_link/core/theme/app_theme.dart';
import 'package:skill_link/features/authentication/screens/login_screen.dart';
import 'package:skill_link/features/worker_directory/screens/find_workers_screen.dart';
import 'package:skill_link/models/user_model.dart';
import 'package:skill_link/models/worker_model.dart';
import 'package:skill_link/providers/auth_provider.dart';
import 'package:skill_link/providers/customer_provider.dart';
import 'package:skill_link/repositories/auth_repository.dart';
import 'package:skill_link/repositories/saved_workers_repository.dart';
import 'package:skill_link/repositories/worker_repository.dart';

class _FakeAuthRepository implements AuthRepository {
  UserModel? userToReturn;

  @override
  Stream<User?> get authStateChanges => const Stream.empty();

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
  Future<UserModel> signInWithEmailAndPassword({required String email, required String password}) async {
    if (userToReturn != null) return userToReturn!;
    throw UnimplementedError();
  }

  @override
  Future<UserModel?> getUserProfile(String uid) async => userToReturn;

  @override
  Future<void> switchActiveRole(String uid, String newRole) async {}

  @override
  Future<UserModel> addRole({required String uid, required String newRole}) async => throw UnimplementedError();

  @override
  Future<void> updateProfile({required String uid, String? fullName, String? phone, String? photoUrl}) async {}

  @override
  Future<void> sendPasswordReset(String email) async {}

  @override
  Future<void> signOut() async {}
}

class _FakeWorkerRepository implements WorkerRepository {
  @override
  Future<WorkerModel?> getWorkerProfile(String uid) async => null;

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

class _FakeSavedWorkersRepository implements SavedWorkersRepository {
  @override
  Future<bool> isWorkerSaved({required String customerId, required String workerId}) async => false;

  @override
  Future<void> toggleSaveWorker({required String customerId, required String workerId}) async {}

  @override
  Stream<List<String>> streamSavedWorkerIds(String customerId) => const Stream.empty();

  @override
  Future<List<WorkerModel>> fetchSavedWorkers(String customerId) async => [];
}

void main() {
  testWidgets('4: LoginScreen preserves and pre-fills registered email address', (WidgetTester tester) async {
    final fakeAuth = _FakeAuthRepository();
    final fakeWorker = _FakeWorkerRepository();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>(
            create: (_) => AuthProvider(
              authRepository: fakeAuth,
              workerRepository: fakeWorker,
            ),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const LoginScreen(initialEmail: 'newuser@example.com'),
        ),
      ),
    );
    await tester.pump();

    // Verify email field is pre-populated
    expect(find.text('newuser@example.com'), findsOneWidget);
    expect(find.text('Sign In'), findsWidgets);
  });

  testWidgets('FindWorkersScreen shows Sign In Required for unauthenticated visitors', (WidgetTester tester) async {
    final fakeAuth = _FakeAuthRepository();
    final fakeWorker = _FakeWorkerRepository();
    final fakeSaved = _FakeSavedWorkersRepository();
    final authProvider = AuthProvider(
      authRepository: fakeAuth,
      workerRepository: fakeWorker,
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
          ChangeNotifierProvider<CustomerProvider>(
            create: (_) => CustomerProvider(
              workerRepository: fakeWorker,
              savedWorkersRepository: fakeSaved,
            ),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(body: FindWorkersScreen()),
        ),
      ),
    );
    await tester.pump();

    // Verify unauthenticated lock screen is displayed
    expect(find.text('Sign In Required'), findsOneWidget);
    expect(find.text('Sign In to Skill-Link'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
  });

  testWidgets('FindWorkersScreen shows Customer Portal Only for worker-only users', (WidgetTester tester) async {
    final fakeAuth = _FakeAuthRepository();
    final fakeWorker = _FakeWorkerRepository();
    final fakeSaved = _FakeSavedWorkersRepository();
    final authProvider = AuthProvider(
      authRepository: fakeAuth,
      workerRepository: fakeWorker,
    );

    final now = DateTime.now();
    fakeAuth.userToReturn = UserModel(
      uid: 'worker_only_uid',
      fullName: 'Worker User',
      email: 'worker@example.com',
      activeRole: 'worker',
      roles: ['worker'],
      accountStatus: 'active',
      createdAt: now,
      updatedAt: now,
    );
    await authProvider.signIn(email: 'worker@example.com', password: 'pass');

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
          ChangeNotifierProvider<CustomerProvider>(
            create: (_) => CustomerProvider(
              workerRepository: fakeWorker,
              savedWorkersRepository: fakeSaved,
            ),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(body: FindWorkersScreen()),
        ),
      ),
    );
    await tester.pump();

    // Verify worker-only access guard is displayed
    expect(find.text('Customer Portal Only'), findsOneWidget);
    expect(find.text('Go to Worker Dashboard'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
  });

  testWidgets('FindWorkersScreen renders search and directory for authenticated customers', (WidgetTester tester) async {
    final fakeAuth = _FakeAuthRepository();
    final fakeWorker = _FakeWorkerRepository();
    final fakeSaved = _FakeSavedWorkersRepository();
    final authProvider = AuthProvider(
      authRepository: fakeAuth,
      workerRepository: fakeWorker,
    );

    final now = DateTime.now();
    fakeAuth.userToReturn = UserModel(
      uid: 'customer_uid',
      fullName: 'Customer User',
      email: 'customer@example.com',
      activeRole: 'customer',
      roles: ['customer'],
      accountStatus: 'active',
      createdAt: now,
      updatedAt: now,
    );
    await authProvider.signIn(email: 'customer@example.com', password: 'pass');

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
          ChangeNotifierProvider<CustomerProvider>(
            create: (_) => CustomerProvider(
              workerRepository: fakeWorker,
              savedWorkersRepository: fakeSaved,
            ),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(body: FindWorkersScreen()),
        ),
      ),
    );
    await tester.pump();

    // Verify Search, Filter action, and Category chips are rendered
    expect(find.text('Find Skilled Workers'), findsOneWidget);
    expect(find.byType(TextField), findsWidgets);
    expect(find.byIcon(Icons.filter_list_rounded), findsOneWidget);
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Electrician'), findsWidgets);
  });
}
