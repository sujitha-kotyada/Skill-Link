import '../models/notification_model.dart';
import 'firestore_service.dart';

class NotificationService {
  final FirestoreService _firestoreService;

  NotificationService({FirestoreService? firestoreService})
      : _firestoreService = firestoreService ?? FirestoreService();

  Stream<List<NotificationModel>> streamUserNotifications(String userId) {
    return _firestoreService.notifications
        .where('recipientId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NotificationModel.fromMap(
                  doc.data() as Map<String, dynamic>,
                  docId: doc.id,
                ))
            .toList());
  }

  Future<void> sendNotification({
    required String recipientId,
    required String title,
    required String message,
    required String type,
    String? relatedId,
  }) async {
    final notification = NotificationModel(
      id: '',
      recipientId: recipientId,
      title: title,
      message: message,
      type: type,
      relatedId: relatedId,
      read: false,
      createdAt: DateTime.now(),
    );

    await _firestoreService.addDocument(
      _firestoreService.notifications,
      notification.toMap(),
    );
  }

  Future<void> markAsRead(String notificationId) async {
    await _firestoreService.updateDocument(
      _firestoreService.notifications,
      notificationId,
      {'read': true},
    );
  }

  Future<void> markAllAsRead(String userId) async {
    final unread = await _firestoreService.notifications
        .where('recipientId', isEqualTo: userId)
        .where('read', isEqualTo: false)
        .get();

    for (final doc in unread.docs) {
      await doc.reference.update({'read': true});
    }
  }
}
