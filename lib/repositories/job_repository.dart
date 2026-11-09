import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../core/constants/app_constants.dart';
import '../core/exceptions/app_exception.dart';
import '../models/job_model.dart';
import '../services/firestore_service.dart';

class JobRepository {
  final FirestoreService _firestoreService;

  JobRepository({FirestoreService? firestoreService})
      : _firestoreService = firestoreService ?? FirestoreService();

  Future<String> createJob(JobModel job) async {
    try {
      final docRef = await _firestoreService.addDocument(
        _firestoreService.jobs,
        job.toMap(),
      );
      return docRef.id;
    } catch (e) {
      throw DatabaseException('Failed to post job: $e');
    }
  }

  Future<void> updateJob(JobModel job) async {
    try {
      await _firestoreService.updateDocument(
        _firestoreService.jobs,
        job.id,
        job.toMap(),
      );
    } catch (e) {
      throw DatabaseException('Failed to update job: $e');
    }
  }

  Future<void> updateJobStatus(String jobId, String status) async {
    try {
      await _firestoreService.updateDocument(
        _firestoreService.jobs,
        jobId,
        {
          'status': status,
          'updatedAt': DateTime.now(),
        },
      );
    } catch (e) {
      throw DatabaseException('Failed to change job status: $e');
    }
  }

  Future<JobModel?> getJobById(String jobId) async {
    try {
      final doc = await _firestoreService.getDocument(_firestoreService.jobs, jobId);
      if (!doc.exists || doc.data() == null) {
        return null;
      }
      return JobModel.fromMap(doc.data() as Map<String, dynamic>, docId: doc.id);
    } catch (e) {
      throw DatabaseException('Failed to load job: $e');
    }
  }

  Stream<List<JobModel>> streamCustomerJobs(String customerId) {
    return _firestoreService.jobs
        .where('customerId', isEqualTo: customerId)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs
          .map((doc) => JobModel.fromMap(doc.data() as Map<String, dynamic>, docId: doc.id))
          .toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  Future<List<JobModel>> fetchAvailableJobs({
    String? category,
    String? searchQuery,
    String? city,
    double? minBudget,
    double? maxBudget,
    String sortBy = 'newest', // 'newest', 'budget_desc', 'budget_asc'
    int limit = 30,
  }) async {
    try {
      Query query = _firestoreService.jobs.where('status', isEqualTo: AppConstants.jobStatusOpen);

      if (category != null && category != 'All' && category.isNotEmpty) {
        query = query.where('category', isEqualTo: category);
      }

      final snapshot = await query.limit(limit).get();

      List<JobModel> jobs = snapshot.docs.map((doc) {
        return JobModel.fromMap(doc.data() as Map<String, dynamic>, docId: doc.id);
      }).toList();

      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final queryLower = searchQuery.trim().toLowerCase();
        jobs = jobs.where((j) {
          final matchTitle = j.title.toLowerCase().contains(queryLower);
          final matchDesc = j.description.toLowerCase().contains(queryLower);
          final matchSkills = j.requiredSkills.any((s) => s.toLowerCase().contains(queryLower));
          return matchTitle || matchDesc || matchSkills;
        }).toList();
      }

      if (city != null && city.trim().isNotEmpty && city.toLowerCase() != 'all') {
        final cityLower = city.trim().toLowerCase();
        jobs = jobs.where((j) => j.city.toLowerCase().contains(cityLower)).toList();
      }

      if (minBudget != null && minBudget > 0) {
        jobs = jobs.where((j) => j.budget >= minBudget).toList();
      }

      if (maxBudget != null && maxBudget > 0) {
        jobs = jobs.where((j) => j.budget <= maxBudget).toList();
      }

      switch (sortBy) {
        case 'budget_desc':
          jobs.sort((a, b) => b.budget.compareTo(a.budget));
          break;
        case 'budget_asc':
          jobs.sort((a, b) => a.budget.compareTo(b.budget));
          break;
        case 'newest':
        default:
          jobs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          break;
      }

      return jobs;
    } catch (e) {
      throw DatabaseException('Failed to load available jobs: $e');
    }
  }

  Stream<List<JobModel>> streamRecentJobs({int limit = 6}) {
    return _firestoreService.jobs
        .where('status', isEqualTo: AppConstants.jobStatusOpen)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs
          .map((doc) => JobModel.fromMap(doc.data() as Map<String, dynamic>, docId: doc.id))
          .toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  Future<void> incrementApplicantCount(String jobId) async {
    try {
      await _firestoreService.updateDocument(
        _firestoreService.jobs,
        jobId,
        {'applicantCount': FieldValue.increment(1)},
      );
    } catch (e) {
      debugPrint('Error incrementing applicant count: $e');
    }
  }
}
