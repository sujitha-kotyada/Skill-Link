import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../core/constants/app_constants.dart';
import '../core/exceptions/app_exception.dart';
import '../models/job_model.dart';
import '../models/worker_model.dart';
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

  static const List<List<String>> _relatedKeywordGroups = [
    ['tutoring', 'tutor', 'teaching', 'teacher', 'education', 'educational', 'tuition', 'coaching', 'academic'],
    ['plumbing', 'plumber', 'pipe', 'leakage', 'leak', 'drain', 'tap', 'faucet', 'water leak', 'water leakage'],
    ['electrician', 'electrical', 'electric', 'wiring', 'circuit', 'switchboard'],
    ['painting', 'painter', 'paint', 'whitewash', 'wall paint', 'house painting'],
    ['carpentry', 'carpenter', 'woodwork', 'furniture repair', 'wood'],
    ['mechanic', 'mechanical', 'automobile', 'vehicle repair', 'car repair', 'bike repair'],
    ['tailor', 'tailoring', 'stitching', 'sewing', 'alteration'],
    ['cleaning', 'cleaner', 'housekeeping', 'sanitization', 'deep clean'],
    ['gardening', 'gardener', 'landscaping', 'lawn', 'plants'],
    ['appliance repair', 'appliance', 'fridge repair', 'washing machine', 'ac repair'],
  ];

  static const Set<String> _stopWords = {
    'job', 'jobs', 'work', 'service', 'services', 'for', 'in', 'on', 'at', 'of',
    'the', 'and', 'a', 'an', 'to', 'need', 'needed', 'wanted', 'looking', 'required',
  };

  /// Checks whether [term] matches any relevant searchable field of [job].
  static bool _jobFieldsContain(JobModel job, String term) {
    final title = job.title.toLowerCase();
    final category = job.category.toLowerCase();
    final description = job.description.toLowerCase();
    final skills = job.requiredSkills.map((s) => s.toLowerCase()).toList();

    return title.contains(term) ||
        category.contains(term) ||
        description.contains(term) ||
        skills.any((s) => s.contains(term));
  }

  /// Returns all keyword variants related to [token], or empty if none apply.
  static Set<String> _getRelatedKeywords(String token) {
    final related = <String>{};
    for (final group in _relatedKeywordGroups) {
      final matchesGroup = group.contains(token) ||
          (token.length >= 4 && group.any((kw) => !kw.contains(' ') && kw.startsWith(token)));
      if (matchesGroup) {
        related.addAll(group);
      }
    }
    return related;
  }

  /// Evaluates if [job] genuinely matches the user's keyword [searchQuery].
  static bool matchesSearch(JobModel job, String searchQuery) {
    final cleanQuery = searchQuery.trim().toLowerCase();
    if (cleanQuery.isEmpty) return true;

    // 1. Direct exact phrase or substring match across title, category, description, and skills
    if (_jobFieldsContain(job, cleanQuery)) {
      return true;
    }

    // 2. Domain-specific keyword equivalence for single phrase / category mismatch (e.g., 'Tutoring' -> 'Tutor')
    final phraseSynonyms = _getRelatedKeywords(cleanQuery);
    if (phraseSynonyms.isNotEmpty) {
      for (final syn in phraseSynonyms) {
        if (_jobFieldsContain(job, syn)) {
          return true;
        }
      }
    }

    // 3. Multi-word token matching
    final rawTokens = cleanQuery.split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toList();
    final significantTokens = rawTokens.where((t) => !_stopWords.contains(t)).toList();
    final tokensToMatch = significantTokens.isNotEmpty ? significantTokens : rawTokens;

    if (tokensToMatch.length > 1) {
      final allTokensMatch = tokensToMatch.every((token) {
        if (_jobFieldsContain(job, token)) return true;
        final tokenSynonyms = _getRelatedKeywords(token);
        return tokenSynonyms.any((syn) => _jobFieldsContain(job, syn));
      });
      if (allTokensMatch) return true;
    } else if (tokensToMatch.length == 1 && tokensToMatch.first != cleanQuery) {
      // Single significant token after stripping stop words (e.g., "Tutoring jobs" -> "tutoring")
      final singleToken = tokensToMatch.first;
      if (_jobFieldsContain(job, singleToken)) return true;
      final tokenSynonyms = _getRelatedKeywords(singleToken);
      if (tokenSynonyms.any((syn) => _jobFieldsContain(job, syn))) return true;
    }

    return false;
  }

  /// Evaluates if [job] genuinely matches the given [worker] profile (category or skills).
  static bool matchesWorkerProfile(JobModel job, WorkerModel? worker) {
    if (worker == null) return false;
    final workerCat = worker.category.trim().toLowerCase();
    final jobCat = job.category.trim().toLowerCase();

    if (workerCat.isNotEmpty && jobCat.isNotEmpty) {
      if (workerCat == jobCat) return true;
      final related = _getRelatedKeywords(workerCat);
      if (related.contains(jobCat)) return true;
    }

    if (workerCat.isNotEmpty && _jobFieldsContain(job, workerCat)) {
      return true;
    }

    for (final skill in worker.skills) {
      final cleanSkill = skill.trim().toLowerCase();
      if (cleanSkill.length < 2) continue;
      final skillInJob = job.requiredSkills.any((js) {
            final jsLower = js.trim().toLowerCase();
            return jsLower == cleanSkill || jsLower.contains(cleanSkill) || cleanSkill.contains(jsLower);
          }) ||
          job.title.toLowerCase().contains(cleanSkill) ||
          job.description.toLowerCase().contains(cleanSkill);
      if (skillInJob) return true;
    }

    return false;
  }

  /// Applies search, category, city, budget, and sorting filters to a list of [jobs].
  static List<JobModel> filterJobs(
    List<JobModel> jobs, {
    String? category,
    String? searchQuery,
    String? city,
    double? minBudget,
    double? maxBudget,
    String sortBy = 'newest',
  }) {
    var filtered = List<JobModel>.from(jobs);

    if (category != null && category != 'All' && category.trim().isNotEmpty) {
      final catLower = category.trim().toLowerCase();
      filtered = filtered.where((j) => j.category.trim().toLowerCase() == catLower).toList();
    }

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      filtered = filtered.where((j) => matchesSearch(j, searchQuery)).toList();
    }

    if (city != null && city.trim().isNotEmpty && city.trim().toLowerCase() != 'all') {
      final cityLower = city.trim().toLowerCase();
      filtered = filtered.where((j) =>
          j.city.toLowerCase().contains(cityLower) ||
          j.location.toLowerCase().contains(cityLower) ||
          j.state.toLowerCase().contains(cityLower)).toList();
    }

    if (minBudget != null && minBudget > 0) {
      filtered = filtered.where((j) => j.budget >= minBudget).toList();
    }

    if (maxBudget != null && maxBudget > 0) {
      filtered = filtered.where((j) => j.budget <= maxBudget).toList();
    }

    switch (sortBy) {
      case 'budget_desc':
        filtered.sort((a, b) => b.budget.compareTo(a.budget));
        break;
      case 'budget_asc':
        filtered.sort((a, b) => a.budget.compareTo(b.budget));
        break;
      case 'newest':
      default:
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
    }

    return filtered;
  }

  Future<List<JobModel>> fetchAvailableJobs({
    String? category,
    String? searchQuery,
    String? city,
    double? minBudget,
    double? maxBudget,
    String sortBy = 'newest', // 'newest', 'budget_desc', 'budget_asc'
    int limit = 100,
  }) async {
    try {
      Query query = _firestoreService.jobs.where('status', isEqualTo: AppConstants.jobStatusOpen);

      if (category != null && category != 'All' && category.isNotEmpty) {
        query = query.where('category', isEqualTo: category);
      }

      final snapshot = await query.limit(limit).get();

      final jobs = snapshot.docs.map((doc) {
        return JobModel.fromMap(doc.data() as Map<String, dynamic>, docId: doc.id);
      }).toList();

      return filterJobs(
        jobs,
        category: category,
        searchQuery: searchQuery,
        city: city,
        minBudget: minBudget,
        maxBudget: maxBudget,
        sortBy: sortBy,
      );
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
