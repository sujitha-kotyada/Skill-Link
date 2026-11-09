import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../models/application_model.dart';
import '../repositories/application_repository.dart';

class ApplicationProvider extends ChangeNotifier {
  final ApplicationRepository _applicationRepository;

  bool _isSubmitting = false;
  String? _errorMessage;

  ApplicationProvider({ApplicationRepository? applicationRepository})
      : _applicationRepository = applicationRepository ?? ApplicationRepository();

  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;

  Stream<List<ApplicationModel>> streamApplicationsForJob(String jobId, {String? customerId}) {
    return _applicationRepository.streamApplicationsForJob(jobId, customerId: customerId);
  }

  Stream<int> streamProposalCountForJob(String jobId, {String? customerId}) {
    return streamApplicationsForJob(jobId, customerId: customerId).map(
      (apps) => countActiveProposals(apps, jobId: jobId),
    );
  }

  Stream<List<ApplicationModel>> streamCustomerApplications(String customerId) {
    return _applicationRepository.streamCustomerApplications(customerId);
  }

  /// Counts active (non-withdrawn) proposals for a specific job or across all jobs.
  static int countActiveProposals(List<ApplicationModel> applications, {String? jobId}) {
    return applications.where((a) {
      final matchesJob = jobId == null || a.jobId == jobId;
      final isActive = a.status != AppConstants.appStatusWithdrawn;
      return matchesJob && isActive;
    }).length;
  }

  /// Formats proposal count text (e.g., "0 Proposals", "1 Proposal", "5 Proposals").
  static String formatProposalCount(int count) {
    if (count == 1) return '1 Proposal';
    return '$count Proposals';
  }

  /// Formats application count text (e.g., "0 Applications", "1 Application", "5 Applications").
  static String formatApplicationCount(int count) {
    if (count == 1) return '1 Application';
    return '$count Applications';
  }

  Stream<List<ApplicationModel>> streamWorkerApplications(String workerId) {
    return _applicationRepository.streamWorkerApplications(workerId);
  }

  Future<ApplicationModel?> getApplicationById(String applicationId) async {
    return _applicationRepository.getApplicationById(applicationId);
  }

  Future<bool> checkAlreadyApplied({required String jobId, required String workerId}) async {
    return _applicationRepository.hasWorkerApplied(jobId: jobId, workerId: workerId);
  }

  Future<bool> applyForJob(ApplicationModel application) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _applicationRepository.submitApplication(application);
      _isSubmitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> acceptApplication(ApplicationModel application) async {
    return _updateStatus(application, AppConstants.appStatusAccepted);
  }

  Future<bool> rejectApplication(ApplicationModel application) async {
    return _updateStatus(application, AppConstants.appStatusRejected);
  }

  Future<bool> withdrawApplication(ApplicationModel application) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _applicationRepository.withdrawApplication(application);
      _isSubmitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to withdraw application: $e';
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> _updateStatus(ApplicationModel application, String newStatus) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _applicationRepository.updateApplicationStatus(
        application: application,
        newStatus: newStatus,
      );
      _isSubmitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update application status: $e';
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }
}

