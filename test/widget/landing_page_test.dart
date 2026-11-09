import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:skill_link/core/constants/app_strings.dart';
import 'package:skill_link/features/landing/screens/landing_page.dart';
import 'package:skill_link/models/user_model.dart';
import 'package:skill_link/models/worker_model.dart';
import 'package:skill_link/providers/auth_provider.dart';
import 'package:skill_link/providers/customer_provider.dart';
import 'package:skill_link/repositories/auth_repository.dart';
import 'package:skill_link/repositories/worker_repository.dart';

class _FakeAuthRepository implements AuthRepository {
  @override
  Stream<User?> get authStateChanges => const Stream.empty();
  @override
  User? get currentFirebaseUser => null;
  @override
  Future<UserModel> registerWithEmailAndPassword({required String fullName, required String email, required String password, required List<String> initialRoles, required String initialActiveRole}) => throw UnimplementedError();
  @override
  Future<UserModel> signInWithEmailAndPassword({required String email, required String password}) => throw UnimplementedError();
  @override
  Future<UserModel?> getUserProfile(String uid) async => null;
  @override
  Future<void> switchActiveRole(String uid, String newRole) async {}
  @override
  Future<UserModel> addRole({required String uid, required String newRole}) => throw UnimplementedError();
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
  Future<List<WorkerModel>> fetchWorkers({String? category, String? searchQuery, String? city, double? maxRate, double? minRating, String sortBy = 'rating_desc', int limit = 20}) async => [];
  @override
  Stream<List<WorkerModel>> streamFeaturedWorkers({int limit = 6}) => const Stream.empty();
}

void main() {
  testWidgets('LandingPage renders hero, branding, headlines and category sections',
      (WidgetTester tester) async {
    // Set a large screen size to test full desktop layout
    tester.view.physicalSize = const Size(1280, 1024);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

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
          ChangeNotifierProvider<CustomerProvider>(
            create: (_) => CustomerProvider(),
          ),
        ],
        child: const MaterialApp(
          home: LandingPage(),
        ),
      ),
    );
    await tester.pump();

    // Verify brand name & hero text
    expect(find.text(AppStrings.appName), findsWidgets);
    expect(find.text(AppStrings.heroHeadline), findsOneWidget);
    expect(find.text(AppStrings.findSkilledWorkers), findsOneWidget);
    expect(find.text(AppStrings.offerYourSkills), findsOneWidget);

    // Verify categories & how it works
    expect(find.text('POPULAR SERVICE CATEGORIES'), findsOneWidget);
    expect(find.text('Electrician'), findsWidgets);
    expect(find.text('Plumber'), findsWidgets);
    expect(find.text('Carpenter'), findsWidgets);

    // Verify 'What is Skill-Link?' section is present
    expect(find.text('What is Skill-Link?'), findsOneWidget);

    // Verify Top Rated Workers section is completely removed from LandingPage
    expect(find.text('TOP RATED LOCAL TALENT'), findsNothing);
    expect(find.text('Explore Skilled Professionals'), findsNothing);
    expect(find.text('Sunil Sharma'), findsNothing);
  });
}

