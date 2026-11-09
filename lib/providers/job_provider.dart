import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../models/job_model.dart';
import '../repositories/job_repository.dart';

class JobProvider extends ChangeNotifier {
  final JobRepository _jobRepository;

  bool _isLoading = false;
  String? _errorMessage;

  JobProvider({JobRepository? jobRepository})
      : _jobRepository = jobRepository ?? JobRepository();

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Stream<List<JobModel>> streamCustomerJobs(String customerId) {
    return _jobRepository.streamCustomerJobs(customerId);
  }

  Stream<List<JobModel>> streamRecentJobs() {
    return _jobRepository.streamRecentJobs();
  }

  Future<String?> createJob(JobModel job) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final id = await _jobRepository.createJob(job);
      _isLoading = false;
      notifyListeners();
      return id;
    } catch (e) {
      _errorMessage = 'Failed to post job: $e';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<bool> updateJob(JobModel job) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _jobRepository.updateJob(job);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update job: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> cancelJob(String jobId) async {
    return _changeJobStatus(jobId, AppConstants.jobStatusCancelled);
  }

  Future<bool> completeJob(String jobId) async {
    return _changeJobStatus(jobId, AppConstants.jobStatusCompleted);
  }

  Future<bool> _changeJobStatus(String jobId, String status) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _jobRepository.updateJobStatus(jobId, status);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update job status: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<JobModel?> getJobById(String jobId) async {
    return _jobRepository.getJobById(jobId);
  }
}
