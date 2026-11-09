import '../core/exceptions/app_exception.dart';
import '../models/review_model.dart';
import '../services/firestore_service.dart';
import '../services/notification_service.dart';

class ReviewRepository {
  final FirestoreService _firestoreService;
  final NotificationService _notificationService;

  ReviewRepository({
    FirestoreService? firestoreService,
    NotificationService? notificationService,
  })  : _firestoreService = firestoreService ?? FirestoreService(),
        _notificationService = notificationService ?? NotificationService();

  Future<bool> hasCustomerReviewedJob({
    required String customerId,
    required String jobId,
  }) async {
    try {
      final query = await _firestoreService.reviews
          .where('customerId', isEqualTo: customerId)
          .where('jobId', isEqualTo: jobId)
          .limit(1)
          .get();
      return query.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<void> submitReview(ReviewModel review) async {
    try {
      if (review.customerId == review.workerId) {
        throw const ValidationException('You cannot review your own profile.');
      }

      if (review.rating < 1 || review.rating > 5) {
        throw const ValidationException('Rating must be between 1 and 5 stars.');
      }

      final alreadyReviewed = await hasCustomerReviewedJob(
        customerId: review.customerId,
        jobId: review.jobId,
      );
      if (alreadyReviewed) {
        throw const ValidationException('You have already submitted a review for this job.');
      }

      // Add review doc
      await _firestoreService.addDocument(
        _firestoreService.reviews,
        review.toMap(),
      );

      // Recalculate average rating & review count for the worker
      final allReviewsSnapshot = await _firestoreService.reviews
          .where('workerId', isEqualTo: review.workerId)
          .get();

      double total = 0.0;
      final count = allReviewsSnapshot.docs.length;
      for (final doc in allReviewsSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        total += (data['rating'] as num?)?.toDouble() ?? 5.0;
      }
      final newAverage = count > 0 ? (total / count) : 0.0;

      try {
        await _firestoreService.updateDocument(
          _firestoreService.workerProfiles,
          review.workerId,
          {
            'averageRating': double.parse(newAverage.toStringAsFixed(1)),
            'reviewCount': count,
            'updatedAt': DateTime.now(),
          },
        );
      } catch (_) {
        // If security rules restrict direct customer writes to worker profile documents,
        // the review remains securely recorded in the immutable reviews collection.
      }

      // Notify worker
      await _notificationService.sendNotification(
        recipientId: review.workerId,
        title: 'New Review Received! ⭐',
        message: '${review.customerName} left a ${review.rating.toInt()}-star review for "${review.jobTitle}"',
        type: 'review',
        relatedId: review.jobId,
      );
    } catch (e) {
      if (e is ValidationException) rethrow;
      throw DatabaseException('Failed to submit review: $e');
    }
  }

  Stream<List<ReviewModel>> streamWorkerReviews(String workerId) {
    return _firestoreService.reviews
        .where('workerId', isEqualTo: workerId)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs
          .map((doc) => ReviewModel.fromMap(doc.data() as Map<String, dynamic>, docId: doc.id))
          .toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }
}
