import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/app_constants.dart';
import '../core/exceptions/app_exception.dart';
import '../models/application_model.dart';
import '../services/firestore_service.dart';
import '../services/notification_service.dart';

class ApplicationRepository {
  final FirestoreService _firestoreService;
  final NotificationService _notificationService;

  ApplicationRepository({
    FirestoreService? firestoreService,
    NotificationService? notificationService,
  })  : _firestoreService = firestoreService ?? FirestoreService(),
        _notificationService = notificationService ?? NotificationService();

  Future<bool> hasWorkerApplied({required String jobId, required String workerId}) async {
    try {
      final query = await _firestoreService.applications
          .where('jobId', isEqualTo: jobId)
          .where('workerId', isEqualTo: workerId)
          .limit(1)
          .get();
      return query.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<String> submitApplication(ApplicationModel application) async {
    try {
      // 1. Check for duplicate application
      final alreadyApplied = await hasWorkerApplied(
        jobId: application.jobId,
        workerId: application.workerId,
      );
      if (alreadyApplied) {
        throw const ValidationException('You have already applied for this job.');
      }

      // 2. Add application document
      final docRef = await _firestoreService.addDocument(
        _firestoreService.applications,
        application.toMap(),
      );

      // Note: Proposal and applicant counts are dynamically derived directly
      // from the applications collection as the single source of truth.
      // This ensures real-time accuracy across submissions, reviews, and withdrawals
      // without conflicting dual-state drift or permission errors.

      // 3. Send notification to the customer
      try {
        await _notificationService.sendNotification(
          recipientId: application.customerId,
          title: 'New job application received',
          message: '${application.workerName} applied for your job: "${application.jobTitle}"',
          type: 'application',
          relatedId: docRef.id,
        );
      } catch (notifError) {
        // Log notification failure separately; application is preserved
        // but not pretending notification delivery succeeded silently
        // in logs.
      }

      return docRef.id;
    } catch (e) {
      if (e is ValidationException) rethrow;
      if (e is AppException) rethrow;
      throw DatabaseException('Failed to submit application: $e');
    }
  }

  Future<ApplicationModel?> getApplicationById(String applicationId) async {
    try {
      final doc = await _firestoreService.getDocument(
        _firestoreService.applications,
        applicationId,
      );
      if (!doc.exists || doc.data() == null) {
        return null;
      }
      return ApplicationModel.fromMap(
        doc.data() as Map<String, dynamic>,
        docId: doc.id,
      );
    } catch (e) {
      if (e is AppException) rethrow;
      throw DatabaseException('Failed to fetch application: $e');
    }
  }

  Stream<List<ApplicationModel>> streamApplicationsForJob(String jobId, {String? customerId}) {
    Query query = _firestoreService.applications.where('jobId', isEqualTo: jobId);
    if (customerId != null && customerId.isNotEmpty) {
      query = query.where('customerId', isEqualTo: customerId);
    }
    return query.snapshots().map((snapshot) {
      final list = snapshot.docs
          .map((doc) => ApplicationModel.fromMap(doc.data() as Map<String, dynamic>, docId: doc.id))
          .toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  Stream<List<ApplicationModel>> streamCustomerApplications(String customerId) {
    return _firestoreService.applications
        .where('customerId', isEqualTo: customerId)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs
          .map((doc) => ApplicationModel.fromMap(doc.data() as Map<String, dynamic>, docId: doc.id))
          .toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  Stream<List<ApplicationModel>> streamWorkerApplications(String workerId) {
    return _firestoreService.applications
        .where('workerId', isEqualTo: workerId)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs
          .map((doc) => ApplicationModel.fromMap(doc.data() as Map<String, dynamic>, docId: doc.id))
          .toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  Future<void> updateApplicationStatus({
    required ApplicationModel application,
    required String newStatus,
  }) async {
    try {
      await _firestoreService.updateDocument(
        _firestoreService.applications,
        application.id,
        {
          'status': newStatus,
          'updatedAt': DateTime.now(),
        },
      );

      // If accepted, also notify worker
      if (newStatus == AppConstants.appStatusAccepted) {
        await _notificationService.sendNotification(
          recipientId: application.workerId,
          title: 'Application Accepted! 🎉',
          message: 'Congratulations! Your application for "${application.jobTitle}" was accepted.',
          type: 'application',
          relatedId: application.id,
        );
      } else if (newStatus == AppConstants.appStatusRejected) {
        await _notificationService.sendNotification(
          recipientId: application.workerId,
          title: 'Application Update',
          message: 'Your application for "${application.jobTitle}" was not selected.',
          type: 'application',
          relatedId: application.id,
        );
      }
    } catch (e) {
      throw DatabaseException('Failed to update application status: $e');
    }
  }

  Future<void> withdrawApplication(ApplicationModel application) async {
    try {
      await _firestoreService.updateDocument(
        _firestoreService.applications,
        application.id,
        {
          'status': AppConstants.appStatusWithdrawn,
          'updatedAt': DateTime.now(),
        },
      );
    } catch (e) {
      throw DatabaseException('Failed to withdraw application: $e');
    }
  }
}
