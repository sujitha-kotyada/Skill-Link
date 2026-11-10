import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:skill_link/features/jobs/screens/browse_jobs_screen.dart';
import 'package:skill_link/models/job_model.dart';
import 'package:skill_link/models/worker_model.dart';
import 'package:skill_link/providers/worker_provider.dart';
import 'package:skill_link/repositories/job_repository.dart';
import 'package:skill_link/repositories/worker_repository.dart';

class _FakeJobRepository implements JobRepository {
  final List<JobModel> allJobs;

  _FakeJobRepository(this.allJobs);

  @override
  Future<List<JobModel>> fetchAvailableJobs({
    String? category,
    String? searchQuery,
    String? city,
    double? minBudget,
    double? maxBudget,
    String sortBy = 'newest',
    int limit = 100,
  }) async {
    return JobRepository.filterJobs(
      allJobs,
      category: category,
      searchQuery: searchQuery,
      city: city,
      minBudget: minBudget,
      maxBudget: maxBudget,
      sortBy: sortBy,
    );
  }

  @override
  Future<String> createJob(JobModel job) => throw UnimplementedError();
  @override
  Future<void> updateJob(JobModel job) => throw UnimplementedError();
  @override
  Future<void> updateJobStatus(String jobId, String status) => throw UnimplementedError();
  @override
  Future<JobModel?> getJobById(String jobId) async => null;
  @override
  Stream<List<JobModel>> streamCustomerJobs(String customerId) => const Stream.empty();
  @override
  Stream<List<JobModel>> streamRecentJobs({int limit = 6}) => const Stream.empty();
  @override
  Future<void> incrementApplicantCount(String jobId) async {}
}

class _FakeWorkerRepository implements WorkerRepository {
  final WorkerModel? workerProfile;

  _FakeWorkerRepository(this.workerProfile);

  @override
  Future<WorkerModel?> getWorkerProfile(String uid) async => workerProfile;
  @override
  Future<void> saveWorkerProfile(WorkerModel worker) async {}
  @override
  Future<List<WorkerModel>> fetchWorkers({String? category, String? searchQuery, String? city, double? maxRate, double? minRating, String sortBy = 'rating_desc', int limit = 20}) async => [];
  @override
  Stream<List<WorkerModel>> streamFeaturedWorkers({int limit = 6}) => const Stream.empty();
}

void main() {
  final now = DateTime(2026, 11, 10, 10, 0);

  final waterLeakageJob = JobModel(
    id: 'job-plumbing-1',
    customerId: 'cust-1',
    customerName: 'Suresh',
    title: 'Water Leakage',
    category: 'Plumber',
    description: 'Kitchen sink pipe leaking badly and tap needs replacement.',
    requiredSkills: ['Pipe Repair', 'Leakage Fix'],
    location: 'Indiranagar',
    city: 'Bengaluru',
    state: 'Karnataka',
    budget: 800,
    createdAt: now.subtract(const Duration(hours: 2)),
    updatedAt: now.subtract(const Duration(hours: 2)),
  );

  final mathsTutorJob = JobModel(
    id: 'job-tutor-1',
    customerId: 'cust-2',
    customerName: 'Anita',
    title: 'Class 10 Mathematics Tutor',
    category: 'Tutor',
    description: 'Looking for an experienced teacher for algebra home tuition.',
    requiredSkills: ['Mathematics', 'Teaching'],
    location: 'Koramangala',
    city: 'Bengaluru',
    state: 'Karnataka',
    budget: 2500,
    createdAt: now.subtract(const Duration(hours: 1)),
    updatedAt: now.subtract(const Duration(hours: 1)),
  );

  final plumberWorker = WorkerModel(
    uid: 'worker-plumber',
    fullName: 'Ramesh',
    headline: 'Master Plumber',
    description: 'Expert in pipe leakage repair',
    skills: ['Pipe Repair', 'Plumbing'],
    category: 'Plumber',
    experienceYears: 8,
    city: 'Bengaluru',
    state: 'Karnataka',
    locality: 'Indiranagar',
    rate: 500,
    availability: 'Available',
    createdAt: now,
    updatedAt: now,
  );

  Widget buildTestWidget(WorkerProvider provider) {
    return ChangeNotifierProvider<WorkerProvider>.value(
      value: provider,
      child: const MaterialApp(
        home: BrowseJobsScreen(),
      ),
    );
  }

  testWidgets('BrowseJobsScreen separates search results from profile recommendations and handles empty/clear flows',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 1024);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final workerProvider = WorkerProvider(
      workerRepository: _FakeWorkerRepository(plumberWorker),
      jobRepository: _FakeJobRepository([waterLeakageJob, mathsTutorJob]),
    );
    await workerProvider.loadProfile('worker-plumber');

    await tester.pumpWidget(buildTestWidget(workerProvider));
    await tester.pumpAndSettle();

    // Initially, Recommended for Your Profile and All Open Jobs are shown separately
    expect(find.text('Recommended for Your Profile'), findsOneWidget);
    expect(find.text('All Open Jobs (2)'), findsOneWidget);
    expect(find.text('Water Leakage'), findsWidgets);
    expect(find.text('Class 10 Mathematics Tutor'), findsOneWidget);
    expect(find.text('Matched your profile'), findsWidgets);
    expect(find.text('Apply Now'), findsWidgets);

    // Search for "Tutoring" using live text change
    final searchField = find.byType(TextField).first;
    await tester.enterText(searchField, 'Tutoring');
    await tester.pumpAndSettle();

    // Must show tutoring job with "Matched your search", and NOT Water Leakage or profile recommendation
    expect(find.text('Class 10 Mathematics Tutor'), findsOneWidget);
    expect(find.text('Water Leakage'), findsNothing);
    expect(find.text('Matched your search'), findsOneWidget);
    expect(find.text('Matched your profile'), findsNothing);
    expect(find.text('Recommended for Your Profile'), findsNothing);

    // Search for a non-existent keyword -> displays exact empty state with no fallback
    await tester.enterText(searchField, 'Spacecraft Repair');
    await tester.pumpAndSettle();

    expect(find.text('No jobs found for your search.'), findsOneWidget);
    expect(find.text('Water Leakage'), findsNothing);
    expect(find.text('Class 10 Mathematics Tutor'), findsNothing);
    expect(find.text('Clear Search'), findsOneWidget);

    // Tap Clear Search -> restores full job list
    await tester.tap(find.text('Clear Search'));
    await tester.pumpAndSettle();

    expect(find.text('Recommended for Your Profile'), findsOneWidget);
    expect(find.text('All Open Jobs (2)'), findsOneWidget);
    expect(find.text('Water Leakage'), findsWidgets);
    expect(find.text('Class 10 Mathematics Tutor'), findsOneWidget);
  });
}

