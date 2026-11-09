import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/exceptions/app_exception.dart';
import '../models/worker_model.dart';
import '../services/firestore_service.dart';
import 'worker_repository.dart';

class SavedWorkersRepository {
  final FirestoreService _firestoreService;
  final WorkerRepository _workerRepository;

  SavedWorkersRepository({
    FirestoreService? firestoreService,
    WorkerRepository? workerRepository,
  })  : _firestoreService = firestoreService ?? FirestoreService(),
        _workerRepository = workerRepository ?? WorkerRepository();

  Future<bool> isWorkerSaved({
    required String customerId,
    required String workerId,
  }) async {
    try {
      final docId = '${customerId}_$workerId';
      final doc = await _firestoreService.getDocument(_firestoreService.savedWorkers, docId);
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  Future<void> toggleSaveWorker({
    required String customerId,
    required String workerId,
  }) async {
    try {
      final docId = '${customerId}_$workerId';
      final isSaved = await isWorkerSaved(customerId: customerId, workerId: workerId);

      if (isSaved) {
        await _firestoreService.deleteDocument(_firestoreService.savedWorkers, docId);
      } else {
        await _firestoreService.setDocument(
          _firestoreService.savedWorkers,
          docId,
          {
            'customerId': customerId,
            'workerId': workerId,
            'createdAt': Timestamp.now(),
          },
        );
      }
    } catch (e) {
      throw DatabaseException('Failed to update saved worker: $e');
    }
  }

  Stream<List<String>> streamSavedWorkerIds(String customerId) {
    return _firestoreService.savedWorkers
        .where('customerId', isEqualTo: customerId)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => doc.get('workerId') as String).toList());
  }

  Future<List<WorkerModel>> fetchSavedWorkers(String customerId) async {
    try {
      final snapshot = await _firestoreService.savedWorkers
          .where('customerId', isEqualTo: customerId)
          .get();

      final List<WorkerModel> list = [];
      for (final doc in snapshot.docs) {
        final workerId = doc.get('workerId') as String?;
        if (workerId != null) {
          final worker = await _workerRepository.getWorkerProfile(workerId);
          if (worker != null) {
            list.add(worker);
          }
        }
      }
      return list;
    } catch (e) {
      throw DatabaseException('Failed to load saved workers: $e');
    }
  }
}

