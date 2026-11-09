import 'package:flutter_test/flutter_test.dart';
import 'package:skill_link/core/constants/app_constants.dart';
import 'package:skill_link/models/application_model.dart';
import 'package:skill_link/models/job_model.dart';
import 'package:skill_link/models/notification_model.dart';
import 'package:skill_link/models/review_model.dart';
import 'package:skill_link/models/user_model.dart';
import 'package:skill_link/models/worker_model.dart';

void main() {
  group('Data Models & Serialization Tests', () {
    test('UserModel serialization and role evaluation', () {
      final now = DateTime.now();
      final user = UserModel(
        uid: 'user_123',
        fullName: 'Vikram Singh',
        email: 'vikram@example.com',
        activeRole: AppConstants.roleCustomer,
        roles: [AppConstants.roleCustomer, AppConstants.roleWorker],
        createdAt: now,
        updatedAt: now,
      );

      expect(user.isCustomer, isTrue);
      expect(user.isWorker, isTrue);
      expect(user.hasBothRoles, isTrue);
      expect(user.isCustomerActive, isTrue);
      expect(user.isWorkerActive, isFalse);
      expect(user.canSwitchTo(AppConstants.roleWorker), isTrue);

      final map = user.toMap();
      expect(map['uid'], 'user_123');
      expect(map['email'], 'vikram@example.com');
      expect(map['activeRole'], AppConstants.roleCustomer);
      expect(map['roles'], contains(AppConstants.roleWorker));

      final deserialized = UserModel.fromMap(map, docId: 'user_123');
      expect(deserialized.uid, 'user_123');
      expect(deserialized.fullName, 'Vikram Singh');
      expect(deserialized.hasBothRoles, isTrue);
    });

    test('WorkerModel serialization and computed getters', () {
      final now = DateTime.now();
      final worker = WorkerModel(
        uid: 'worker_456',
        fullName: 'Rajesh Carpenter',
        headline: 'Master Woodcrafter',
        description: 'Expert in custom cabinetry',
        skills: ['Carpentry', 'Wood Polishing'],
        category: AppConstants.categoryCarpenter,
        experienceYears: 10,
        city: 'Bengaluru',
        state: 'Karnataka',
        locality: 'Indiranagar',
        rate: 550.0,
        rateType: AppConstants.rateTypeHourly,
        availability: 'Immediate (Full-time)',
        averageRating: 4.9,
        reviewCount: 28,
        createdAt: now,
        updatedAt: now,
      );

      expect(worker.locationString, 'Indiranagar, Bengaluru');

      final map = worker.toMap();
      expect(map['skills'], contains('Carpentry'));
      expect(map['rate'], 550.0);

      final deserialized = WorkerModel.fromMap(map, docId: 'worker_456');
      expect(deserialized.uid, 'worker_456');
      expect(deserialized.headline, 'Master Woodcrafter');
      expect(deserialized.averageRating, 4.9);
      expect(deserialized.reviewCount, 28);
    });

    test('JobModel status getters and copyWith', () {
      final now = DateTime.now();
      final job = JobModel(
        id: 'job_789',
        customerId: 'customer_111',
        customerName: 'Priya Mehta',
        title: 'Fix Kitchen Sink Pipe Leak',
        category: AppConstants.categoryPlumber,
        description: 'Under-sink pipe is dripping water continuously',
        location: 'Koramangala 4th Block',
        city: 'Bengaluru',
        state: 'Karnataka',
        budget: 600.0,
        status: AppConstants.jobStatusOpen,
        createdAt: now,
        updatedAt: now,
      );

      expect(job.isOpen, isTrue);
      expect(job.isCompleted, isFalse);

      final inProgressJob = job.copyWith(status: AppConstants.jobStatusInProgress);
      expect(inProgressJob.isInProgress, isTrue);
      expect(inProgressJob.isOpen, isFalse);

      final completedJob = job.copyWith(status: AppConstants.jobStatusCompleted);
      expect(completedJob.isCompleted, isTrue);

      final map = job.toMap();
      final restored = JobModel.fromMap(map, docId: 'job_789');
      expect(restored.title, 'Fix Kitchen Sink Pipe Leak');
      expect(restored.budget, 600.0);
    });

    test('ApplicationModel lifecycle states', () {
      final now = DateTime.now();
      final app = ApplicationModel(
        id: 'app_999',
        jobId: 'job_789',
        jobTitle: 'Fix Kitchen Sink Pipe Leak',
        customerId: 'customer_111',
        workerId: 'worker_456',
        workerName: 'Rajesh Carpenter',
        workerCategory: 'Plumber',
        message: 'I can come today at 3 PM and fix this within 1 hour.',
        proposedRate: 500.0,
        status: AppConstants.appStatusApplied,
        createdAt: now,
        updatedAt: now,
      );

      expect(app.isApplied, isTrue);
      expect(app.isAccepted, isFalse);

      final accepted = app.copyWith(status: AppConstants.appStatusAccepted);
      expect(accepted.isAccepted, isTrue);
      expect(accepted.isApplied, isFalse);

      final rejected = app.copyWith(status: AppConstants.appStatusRejected);
      expect(rejected.isRejected, isTrue);

      final withdrawn = app.copyWith(status: AppConstants.appStatusWithdrawn);
      expect(withdrawn.isWithdrawn, isTrue);
    });

    test('ReviewModel validation logic and calculation', () {
      final now = DateTime.now();
      final review = ReviewModel(
        id: 'rev_101',
        customerId: 'customer_111',
        customerName: 'Priya Mehta',
        workerId: 'worker_456',
        jobId: 'job_789',
        jobTitle: 'Fix Kitchen Sink Pipe Leak',
        rating: 5.0,
        comment: 'Super fast and clean work! Very professional.',
        createdAt: now,
      );

      expect(review.rating, 5.0);
      expect(review.customerId != review.workerId, isTrue);

      final map = review.toMap();
      final restored = ReviewModel.fromMap(map, docId: 'rev_101');
      expect(restored.comment, 'Super fast and clean work! Very professional.');
    });

    test('NotificationModel read status and types', () {
      final now = DateTime.now();
      final notif = NotificationModel(
        id: 'notif_202',
        recipientId: 'worker_456',
        title: 'New Job Application Accepted',
        message: 'Your proposal was accepted by Priya Mehta',
        type: 'application',
        read: false,
        createdAt: now,
      );

      expect(notif.read, isFalse);
      final readNotif = notif.copyWith(read: true);
      expect(readNotif.read, isTrue);
    });
  });
}
