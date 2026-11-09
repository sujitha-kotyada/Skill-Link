import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/exceptions/app_exception.dart';
import '../models/worker_model.dart';
import '../services/firestore_service.dart';

class WorkerRepository {
  final FirestoreService _firestoreService;

  WorkerRepository({FirestoreService? firestoreService})
      : _firestoreService = firestoreService ?? FirestoreService();

  Future<WorkerModel?> getWorkerProfile(String uid) async {
    try {
      final doc = await _firestoreService.getDocument(_firestoreService.workerProfiles, uid);
      if (!doc.exists || doc.data() == null) {
        return null;
      }
      return WorkerModel.fromMap(doc.data() as Map<String, dynamic>, docId: doc.id);
    } catch (e) {
      if (e is AppException) rethrow;
      throw DatabaseException('Failed to fetch worker profile: $e');
    }
  }

  Future<void> saveWorkerProfile(WorkerModel worker) async {
    try {
      await _firestoreService.setDocument(
        _firestoreService.workerProfiles,
        worker.uid,
        worker.toMap(),
        merge: true,
      );
    } catch (e) {
      if (e is AppException) rethrow;
      throw DatabaseException('Failed to save worker profile: $e');
    }
  }

  Future<List<WorkerModel>> fetchWorkers({
    String? category,
    String? searchQuery,
    String? city,
    double? maxRate,
    double? minRating,
    String sortBy = 'rating_desc', // 'rating_desc', 'rate_asc', 'experience_desc'
    int limit = 20,
  }) async {
    try {
      Query query = _firestoreService.workerProfiles;

      if (category != null && category != 'All' && category.isNotEmpty) {
        query = query.where('category', isEqualTo: category);
      }

      final snapshot = await query.limit(limit).get();

      List<WorkerModel> workers = snapshot.docs.map((doc) {
        return WorkerModel.fromMap(doc.data() as Map<String, dynamic>, docId: doc.id);
      }).toList();

      // In-memory filtering for advanced criteria to support full-text search and client-side sorting without requiring dozens of composite indexes
      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final queryLower = searchQuery.trim().toLowerCase();
        workers = workers.where((w) {
          final matchName = w.fullName.toLowerCase().contains(queryLower);
          final matchHeadline = w.headline.toLowerCase().contains(queryLower);
          final matchCategory = w.category.toLowerCase().contains(queryLower);
          final matchSkills = w.skills.any((s) => s.toLowerCase().contains(queryLower));
          return matchName || matchHeadline || matchCategory || matchSkills;
        }).toList();
      }

      if (city != null && city.trim().isNotEmpty && city.toLowerCase() != 'all') {
        final cityLower = city.trim().toLowerCase();
        workers = workers.where((w) => w.city.toLowerCase().contains(cityLower)).toList();
      }

      if (maxRate != null && maxRate > 0) {
        workers = workers.where((w) => w.rate <= maxRate).toList();
      }

      if (minRating != null && minRating > 0) {
        workers = workers.where((w) => w.averageRating >= minRating).toList();
      }

      // Sorting
      switch (sortBy) {
        case 'rate_asc':
          workers.sort((a, b) => a.rate.compareTo(b.rate));
          break;
        case 'rate_desc':
          workers.sort((a, b) => b.rate.compareTo(a.rate));
          break;
        case 'experience_desc':
          workers.sort((a, b) => b.experienceYears.compareTo(a.experienceYears));
          break;
        case 'rating_desc':
        default:
          workers.sort((a, b) => b.averageRating.compareTo(a.averageRating));
          break;
      }

      return workers;
    } catch (e) {
      throw DatabaseException('Failed to search workers: $e');
    }
  }

  Stream<List<WorkerModel>> streamFeaturedWorkers({int limit = 6}) {
    return _firestoreService.workerProfiles
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => WorkerModel.fromMap(doc.data() as Map<String, dynamic>, docId: doc.id))
            .toList());
  }
}
