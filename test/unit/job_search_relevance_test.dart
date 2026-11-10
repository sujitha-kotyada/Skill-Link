import 'package:flutter_test/flutter_test.dart';
import 'package:skill_link/models/job_model.dart';
import 'package:skill_link/models/worker_model.dart';
import 'package:skill_link/providers/worker_provider.dart';
import 'package:skill_link/repositories/job_repository.dart';
import 'package:skill_link/repositories/worker_repository.dart';

class _FakeJobRepository implements JobRepository {
  final List<JobModel> allJobs;
  Duration simulatedDelay = Duration.zero;

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
    if (simulatedDelay > Duration.zero) {
      await Future.delayed(simulatedDelay);
    }
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
    description: 'Looking for an experienced teacher for algebra and geometry home tuition.',
    requiredSkills: ['Mathematics', 'Teaching', 'CBSE'],
    location: 'Koramangala',
    city: 'Bengaluru',
    state: 'Karnataka',
    budget: 2500,
    createdAt: now.subtract(const Duration(hours: 1)),
    updatedAt: now.subtract(const Duration(hours: 1)),
  );

  final scienceTutorJob = JobModel(
    id: 'job-tutor-2',
    customerId: 'cust-3',
    customerName: 'Vikram',
    title: 'Educational Coaching for Science',
    category: 'Tutor',
    description: 'Evening tutoring sessions for physics and chemistry.',
    requiredSkills: ['Physics', 'Chemistry'],
    location: 'Bandra',
    city: 'Mumbai',
    state: 'Maharashtra',
    budget: 3000,
    createdAt: now,
    updatedAt: now,
  );

  final electricianJob = JobModel(
    id: 'job-elec-1',
    customerId: 'cust-4',
    customerName: 'Meera',
    title: 'Switchboard and Fan Electrical Repair',
    category: 'Electrician',
    description: 'Ceiling fan capacitor replacement and main switchboard wiring check.',
    requiredSkills: ['Wiring', 'Electrical Repair'],
    location: 'Jayanagar',
    city: 'Bengaluru',
    state: 'Karnataka',
    budget: 600,
    createdAt: now.subtract(const Duration(hours: 3)),
    updatedAt: now.subtract(const Duration(hours: 3)),
  );

  final painterJob = JobModel(
    id: 'job-paint-1',
    customerId: 'cust-5',
    customerName: 'Rahul',
    title: '2BHK House Painting',
    category: 'Painter',
    description: 'Interior wall painting and primer work for living room.',
    requiredSkills: ['Wall Painting', 'Primer'],
    location: 'HSR Layout',
    city: 'Bengaluru',
    state: 'Karnataka',
    budget: 12000,
    createdAt: now.subtract(const Duration(hours: 4)),
    updatedAt: now.subtract(const Duration(hours: 4)),
  );

  final allJobs = [
    waterLeakageJob,
    mathsTutorJob,
    scienceTutorJob,
    electricianJob,
    painterJob,
  ];

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

  final tutorWorker = WorkerModel(
    uid: 'worker-tutor',
    fullName: 'Priya',
    headline: 'Math & Science Tutor',
    description: 'Experienced home tutor',
    skills: ['Mathematics', 'Teaching'],
    category: 'Tutor',
    experienceYears: 5,
    city: 'Bengaluru',
    state: 'Karnataka',
    locality: 'Koramangala',
    rate: 600,
    availability: 'Available',
    createdAt: now,
    updatedAt: now,
  );

  group('JobRepository Search Relevance Tests', () {
    test('1. Searching for Tutoring returns tutoring/teaching jobs and does NOT return Water Leakage', () {
      final results = JobRepository.filterJobs(allJobs, searchQuery: 'Tutoring');

      expect(results.map((j) => j.id), containsAll(['job-tutor-1', 'job-tutor-2']));
      expect(results.any((j) => j.title == 'Water Leakage'), isFalse);
      expect(results.length, 2);
    });

    test('2. Searching for Plumbing returns Water Leakage and relevant plumbing jobs', () {
      final results = JobRepository.filterJobs(allJobs, searchQuery: 'Plumbing');

      expect(results.map((j) => j.id), ['job-plumbing-1']);
      expect(results.first.title, 'Water Leakage');
    });

    test('2b. Searching for Water Leakage, Electrician, and Painting returns relevant matches only', () {
      final leakageResults = JobRepository.filterJobs(allJobs, searchQuery: 'Water Leakage');
      expect(leakageResults.map((j) => j.id), ['job-plumbing-1']);

      final electricianResults = JobRepository.filterJobs(allJobs, searchQuery: 'Electrician');
      expect(electricianResults.map((j) => j.id), ['job-elec-1']);

      final paintingResults = JobRepository.filterJobs(allJobs, searchQuery: 'Painting');
      expect(paintingResults.map((j) => j.id), ['job-paint-1']);
    });

    test('3. Search is case-insensitive and ignores leading/trailing whitespace', () {
      final results = JobRepository.filterJobs(allJobs, searchQuery: '   tUtOrInG   ');

      expect(results.length, 2);
      expect(results.map((j) => j.id), containsAll(['job-tutor-1', 'job-tutor-2']));
    });

    test('4. Partial keyword matching matches relevant job fields', () {
      expect(
        JobRepository.filterJobs(allJobs, searchQuery: 'tuto').map((j) => j.id),
        containsAll(['job-tutor-1', 'job-tutor-2']),
      );
      expect(
        JobRepository.filterJobs(allJobs, searchQuery: 'leak').map((j) => j.id),
        ['job-plumbing-1'],
      );
      expect(
        JobRepository.filterJobs(allJobs, searchQuery: 'electr').map((j) => j.id),
        ['job-elec-1'],
      );
      expect(
        JobRepository.filterJobs(allJobs, searchQuery: 'paint').map((j) => j.id),
        ['job-paint-1'],
      );
    });

    test('5. Empty search query returns full unfiltered job list', () {
      final results = JobRepository.filterJobs(allJobs, searchQuery: '   ');
      expect(results.length, 5);
    });

    test('6. Non-matching search query returns empty list with no fallback unrelated jobs', () {
      final results = JobRepository.filterJobs(allJobs, searchQuery: 'Quantum Astrophysics');
      expect(results, isEmpty);
    });

    test('8. Search combines properly with city, category, and minimum budget filters', () {
      // Tutoring jobs exist in Bengaluru (2500) and Mumbai (3000)
      final bengaluruTutoring = JobRepository.filterJobs(
        allJobs,
        searchQuery: 'Tutoring',
        city: 'Bengaluru',
      );
      expect(bengaluruTutoring.map((j) => j.id), ['job-tutor-1']);

      // Search Tutoring with incompatible category Plumber must return empty
      final conflictingCategory = JobRepository.filterJobs(
        allJobs,
        searchQuery: 'Tutoring',
        category: 'Plumber',
      );
      expect(conflictingCategory, isEmpty);

      // Budget filter combined with Tutoring search
      final highBudgetTutoring = JobRepository.filterJobs(
        allJobs,
        searchQuery: 'Tutoring',
        minBudget: 2800,
      );
      expect(highBudgetTutoring.map((j) => j.id), ['job-tutor-2']);
    });
  });

  group('Worker Profile Recommendation Separation Tests', () {
    test('9. Profile matching checks category and skills without contaminating unrelated workers', () {
      // Plumber worker matches Water Leakage, does NOT match Math Tutor
      expect(JobRepository.matchesWorkerProfile(waterLeakageJob, plumberWorker), isTrue);
      expect(JobRepository.matchesWorkerProfile(mathsTutorJob, plumberWorker), isFalse);

      // Tutor worker matches Math & Science tutors, does NOT match Water Leakage
      expect(JobRepository.matchesWorkerProfile(mathsTutorJob, tutorWorker), isTrue);
      expect(JobRepository.matchesWorkerProfile(scienceTutorJob, tutorWorker), isTrue);
      expect(JobRepository.matchesWorkerProfile(waterLeakageJob, tutorWorker), isFalse);

      // Null worker profile never matches
      expect(JobRepository.matchesWorkerProfile(waterLeakageJob, null), isFalse);
    });

    test('9b. WorkerProvider isolates search results from profile recommendations', () async {
      final fakeRepo = _FakeJobRepository(allJobs);
      final fakeWorkerRepo = _FakeWorkerRepository(plumberWorker);
      final provider = WorkerProvider(
        workerRepository: fakeWorkerRepo,
        jobRepository: fakeRepo,
      );

      await provider.loadProfile('worker-plumber');
      await provider.fetchAvailableJobs();
      await provider.fetchRecommendedJobs();

      // Even though the worker is a Plumber whose recommended job is Water Leakage...
      expect(provider.getRecommendedJobs().map((j) => j.id), ['job-plumbing-1']);

      // ...searching for Tutoring MUST return Tutoring jobs and NOT Water Leakage!
      provider.setJobSearchQuery('Tutoring');
      // Verify old results are immediately cleared before async fetch settles
      expect(provider.availableJobs, isEmpty);

      await Future.delayed(const Duration(milliseconds: 50));
      expect(provider.availableJobs.map((j) => j.id), containsAll(['job-tutor-1', 'job-tutor-2']));
      expect(provider.availableJobs.any((j) => j.title == 'Water Leakage'), isFalse);

      // Recommended jobs remain separate and unaffected by searchQuery
      expect(provider.getRecommendedJobs().map((j) => j.id), ['job-plumbing-1']);

      // Clearing search restores the full list
      provider.clearSearchQuery();
      await Future.delayed(const Duration(milliseconds: 50));
      expect(provider.availableJobs.length, 5);
    });
  });
}

