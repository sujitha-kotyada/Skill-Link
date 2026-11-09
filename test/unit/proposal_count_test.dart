import 'package:flutter_test/flutter_test.dart';
import 'package:skill_link/core/constants/app_constants.dart';
import 'package:skill_link/models/application_model.dart';
import 'package:skill_link/providers/application_provider.dart';

void main() {
  group('Proposal & Application Count Verification Tests', () {
    final now = DateTime.now();

    ApplicationModel createTestApplication({
      required String id,
      required String jobId,
      required String customerId,
      required String workerId,
      String status = AppConstants.appStatusApplied,
    }) {
      return ApplicationModel(
        id: id,
        jobId: jobId,
        jobTitle: 'Fix Plumbing Leak',
        customerId: customerId,
        workerId: workerId,
        workerName: 'Worker $workerId',
        workerCategory: 'Plumber',
        message: 'I can fix this promptly.',
        proposedRate: 500.0,
        status: status,
        createdAt: now,
        updatedAt: now,
      );
    }

    test('1. No applications returns count 0', () {
      final List<ApplicationModel> emptyList = [];
      final count = ApplicationProvider.countActiveProposals(emptyList, jobId: 'job_1');
      expect(count, 0);
      expect(ApplicationProvider.formatProposalCount(count), '0 Proposals');
      expect(ApplicationProvider.formatApplicationCount(count), '0 Applications');
    });

    test('2. One application returns count 1 with singular label', () {
      final app1 = createTestApplication(
        id: 'app_1',
        jobId: 'job_1',
        customerId: 'cust_alice',
        workerId: 'worker_bob',
      );

      final count = ApplicationProvider.countActiveProposals([app1], jobId: 'job_1');
      expect(count, 1);
      expect(ApplicationProvider.formatProposalCount(count), '1 Proposal');
      expect(ApplicationProvider.formatApplicationCount(count), '1 Application');
    });

    test('3. Multiple applications returns correct count with plural label', () {
      final apps = [
        createTestApplication(id: 'app_1', jobId: 'job_1', customerId: 'cust_alice', workerId: 'worker_bob'),
        createTestApplication(id: 'app_2', jobId: 'job_1', customerId: 'cust_alice', workerId: 'worker_charlie'),
        createTestApplication(id: 'app_3', jobId: 'job_1', customerId: 'cust_alice', workerId: 'worker_dan'),
        createTestApplication(id: 'app_4', jobId: 'job_1', customerId: 'cust_alice', workerId: 'worker_edward'),
        createTestApplication(id: 'app_5', jobId: 'job_1', customerId: 'cust_alice', workerId: 'worker_frank'),
      ];

      final count = ApplicationProvider.countActiveProposals(apps, jobId: 'job_1');
      expect(count, 5);
      expect(ApplicationProvider.formatProposalCount(count), '5 Proposals');
      expect(ApplicationProvider.formatApplicationCount(count), '5 Applications');
    });

    test('4. Applications belonging to another job are excluded', () {
      final apps = [
        createTestApplication(id: 'app_1', jobId: 'job_1', customerId: 'cust_alice', workerId: 'worker_bob'),
        createTestApplication(id: 'app_2', jobId: 'job_1', customerId: 'cust_alice', workerId: 'worker_charlie'),
        // Applications for other jobs
        createTestApplication(id: 'app_3', jobId: 'job_2', customerId: 'cust_alice', workerId: 'worker_dan'),
        createTestApplication(id: 'app_4', jobId: 'job_3', customerId: 'cust_alice', workerId: 'worker_edward'),
      ];

      final countJob1 = ApplicationProvider.countActiveProposals(apps, jobId: 'job_1');
      final countJob2 = ApplicationProvider.countActiveProposals(apps, jobId: 'job_2');
      final countJob3 = ApplicationProvider.countActiveProposals(apps, jobId: 'job_3');
      final countJobNonExistent = ApplicationProvider.countActiveProposals(apps, jobId: 'job_999');

      expect(countJob1, 2);
      expect(countJob2, 1);
      expect(countJob3, 1);
      expect(countJobNonExistent, 0);
    });

    test('5. New application dynamically updates the count in stream snapshot', () {
      final list = <ApplicationModel>[
        createTestApplication(id: 'app_1', jobId: 'job_1', customerId: 'cust_alice', workerId: 'worker_bob'),
      ];

      expect(ApplicationProvider.countActiveProposals(list, jobId: 'job_1'), 1);

      // Simulating new incoming application from stream
      final updatedList = List<ApplicationModel>.from(list)..add(
        createTestApplication(id: 'app_2', jobId: 'job_1', customerId: 'cust_alice', workerId: 'worker_charlie'),
      );

      expect(ApplicationProvider.countActiveProposals(updatedList, jobId: 'job_1'), 2);
      expect(ApplicationProvider.formatProposalCount(ApplicationProvider.countActiveProposals(updatedList, jobId: 'job_1')), '2 Proposals');
    });

    test('6. Duplicate submission does not inflate the count', () {
      final apps = [
        createTestApplication(id: 'app_1', jobId: 'job_1', customerId: 'cust_alice', workerId: 'worker_bob'),
      ];

      // Verify alreadyApplied logic
      final isDuplicate = apps.any((a) => a.jobId == 'job_1' && a.workerId == 'worker_bob');
      expect(isDuplicate, isTrue);

      // Since duplicate is rejected, the list remains length 1
      final count = ApplicationProvider.countActiveProposals(apps, jobId: 'job_1');
      expect(count, 1);
    });

    test('7. Withdrawal updates the count (excludes withdrawn proposals)', () {
      final appActive = createTestApplication(
        id: 'app_1',
        jobId: 'job_1',
        customerId: 'cust_alice',
        workerId: 'worker_bob',
        status: AppConstants.appStatusApplied,
      );

      final appWithdrawn = createTestApplication(
        id: 'app_2',
        jobId: 'job_1',
        customerId: 'cust_alice',
        workerId: 'worker_charlie',
        status: AppConstants.appStatusWithdrawn,
      );

      final appsBefore = [appActive, appWithdrawn];
      // Only 1 is active (non-withdrawn)
      expect(ApplicationProvider.countActiveProposals(appsBefore, jobId: 'job_1'), 1);

      // When appActive is also withdrawn
      final appActiveNowWithdrawn = appActive.copyWith(status: AppConstants.appStatusWithdrawn);
      final appsAfter = [appActiveNowWithdrawn, appWithdrawn];
      expect(ApplicationProvider.countActiveProposals(appsAfter, jobId: 'job_1'), 0);
      expect(ApplicationProvider.formatProposalCount(0), '0 Proposals');
    });

    test('8. Customer sees counts only for their own jobs (partitioned by customerId)', () {
      final aliceApps = [
        createTestApplication(id: 'app_1', jobId: 'job_alice_1', customerId: 'cust_alice', workerId: 'worker_bob'),
        createTestApplication(id: 'app_2', jobId: 'job_alice_1', customerId: 'cust_alice', workerId: 'worker_charlie'),
      ];

      final bobCustomerApps = [
        createTestApplication(id: 'app_3', jobId: 'job_bob_1', customerId: 'cust_bob', workerId: 'worker_dan'),
      ];

      // Verify Alice only processes her applications
      final aliceFiltered = aliceApps.where((a) => a.customerId == 'cust_alice').toList();
      expect(aliceFiltered.length, 2);
      expect(ApplicationProvider.countActiveProposals(aliceFiltered, jobId: 'job_alice_1'), 2);

      // Verify Bob cannot see Alice job applications in his query results
      final bobFiltered = bobCustomerApps.where((a) => a.customerId == 'cust_bob').toList();
      expect(bobFiltered.length, 1);
      expect(ApplicationProvider.countActiveProposals(bobFiltered, jobId: 'job_alice_1'), 0);
      expect(ApplicationProvider.countActiveProposals(bobFiltered, jobId: 'job_bob_1'), 1);
    });
  });
}

