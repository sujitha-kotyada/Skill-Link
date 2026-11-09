import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import '../core/exceptions/app_exception.dart';
import 'firebase_service.dart';

class StorageService {
  final FirebaseStorage _storage;

  StorageService({FirebaseStorage? storage})
      : _storage = storage ?? FirebaseService.storage;

  Future<String> uploadProfileImage({
    required String userId,
    required Uint8List bytes,
    required String contentType,
  }) async {
    try {
      final ref = _storage.ref().child('users/$userId/profile_${DateTime.now().millisecondsSinceEpoch}.jpg');
      final metadata = SettableMetadata(contentType: contentType);
      final uploadTask = await ref.putData(bytes, metadata);
      return await uploadTask.ref.getDownloadURL();
    } on FirebaseException catch (e) {
      throw AppException('Failed to upload image: ${e.message}', code: e.code);
    } catch (e) {
      throw AppException('An unexpected error occurred during image upload: $e');
    }
  }

  Future<String> uploadWorkerPortfolioImage({
    required String workerId,
    required Uint8List bytes,
    required String contentType,
  }) async {
    try {
      final ref = _storage.ref().child('workers/$workerId/portfolio/${DateTime.now().millisecondsSinceEpoch}.jpg');
      final metadata = SettableMetadata(contentType: contentType);
      final uploadTask = await ref.putData(bytes, metadata);
      return await uploadTask.ref.getDownloadURL();
    } on FirebaseException catch (e) {
      throw AppException('Failed to upload portfolio image: ${e.message}', code: e.code);
    } catch (e) {
      throw AppException('An unexpected error occurred during image upload: $e');
    }
  }
}
