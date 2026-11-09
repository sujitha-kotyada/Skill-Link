import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/exceptions/app_exception.dart';
import 'firebase_service.dart';

class FirestoreService {
  final FirebaseFirestore _firestore;

  FirestoreService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseService.firestore;

  // Collection references
  CollectionReference get users => _firestore.collection('users');
  CollectionReference get workerProfiles => _firestore.collection('workerProfiles');
  CollectionReference get jobs => _firestore.collection('jobs');
  CollectionReference get applications => _firestore.collection('applications');
  CollectionReference get savedWorkers => _firestore.collection('savedWorkers');
  CollectionReference get reviews => _firestore.collection('reviews');
  CollectionReference get notifications => _firestore.collection('notifications');

  Future<DocumentSnapshot> getDocument(CollectionReference col, String docId) async {
    try {
      return await col.doc(docId).get();
    } on FirebaseException catch (e) {
      throw DatabaseException('Failed to fetch document: ${e.message}', code: e.code);
    } catch (e) {
      throw DatabaseException('An error occurred while loading data: $e');
    }
  }

  Future<void> setDocument(
    CollectionReference col,
    String docId,
    Map<String, dynamic> data, {
    bool merge = true,
  }) async {
    try {
      await col.doc(docId).set(data, SetOptions(merge: merge));
    } on FirebaseException catch (e) {
      throw DatabaseException('Failed to save document: ${e.message}', code: e.code);
    } catch (e) {
      throw DatabaseException('An error occurred while saving data: $e');
    }
  }

  Future<void> updateDocument(
    CollectionReference col,
    String docId,
    Map<String, dynamic> data,
  ) async {
    try {
      await col.doc(docId).update(data);
    } on FirebaseException catch (e) {
      throw DatabaseException('Failed to update document: ${e.message}', code: e.code);
    } catch (e) {
      throw DatabaseException('An error occurred while updating data: $e');
    }
  }

  Future<void> deleteDocument(CollectionReference col, String docId) async {
    try {
      await col.doc(docId).delete();
    } on FirebaseException catch (e) {
      throw DatabaseException('Failed to delete document: ${e.message}', code: e.code);
    } catch (e) {
      throw DatabaseException('An error occurred while deleting data: $e');
    }
  }

  Future<DocumentReference> addDocument(
    CollectionReference col,
    Map<String, dynamic> data,
  ) async {
    try {
      return await col.add(data);
    } on FirebaseException catch (e) {
      throw DatabaseException('Failed to create document: ${e.message}', code: e.code);
    } catch (e) {
      throw DatabaseException('An error occurred while creating record: $e');
    }
  }
}

