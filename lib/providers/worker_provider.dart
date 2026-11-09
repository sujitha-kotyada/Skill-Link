import 'package:flutter/material.dart';
import '../core/exceptions/app_exception.dart';
import '../models/job_model.dart';
import '../models/worker_model.dart';
import '../repositories/job_repository.dart';
import '../repositories/worker_repository.dart';

class WorkerProvider extends ChangeNotifier {
  final WorkerRepository _workerRepository;
  final JobRepository _jobRepository;

  WorkerModel? _profile;
  bool _isLoading = false;
  String? _errorMessage;

  // Browse Jobs Filters
  String _selectedCategory = 'All';
  String _searchQuery = '';
  String _selectedCity = '';
  double? _minBudget;
  double? _maxBudget;
  String _sortBy = 'newest';

  List<JobModel> _availableJobs = [];
  bool _isLoadingJobs = false;

  WorkerProvider({
    WorkerRepository? workerRepository,
    JobRepository? jobRepository,
  })  : _workerRepository = workerRepository ?? WorkerRepository(),
        _jobRepository = jobRepository ?? JobRepository();

  WorkerModel? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  String get selectedCity => _selectedCity;
  double? get minBudget => _minBudget;
  double? get maxBudget => _maxBudget;
  String get sortBy => _sortBy;
  List<JobModel> get availableJobs => _availableJobs;
  bool get isLoadingJobs => _isLoadingJobs;

  Future<void> loadProfile(String uid) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _profile = await _workerRepository.getWorkerProfile(uid);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load profile: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> saveProfile(WorkerModel worker) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _workerRepository.saveWorkerProfile(worker);
      _profile = worker;
      _isLoading = false;
      notifyListeners();
      return true;
    } on PermissionException catch (e) {
      _errorMessage = 'Permission denied: Insufficient permissions to save worker profile (${e.message}).';
      _isLoading = false;
      notifyListeners();
      return false;
    } on AppException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Failed to save profile: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void setJobCategory(String category) {
    _selectedCategory = category;
    fetchAvailableJobs();
  }

  void setJobSearchQuery(String query) {
    _searchQuery = query;
    fetchAvailableJobs();
  }

  void setJobFilters({
    String? category,
    String? city,
    double? minBudget,
    double? maxBudget,
    String? sortBy,
  }) {
    if (category != null) _selectedCategory = category;
    if (city != null) _selectedCity = city;
    _minBudget = minBudget;
    _maxBudget = maxBudget;
    if (sortBy != null) _sortBy = sortBy;
    fetchAvailableJobs();
  }

  void clearJobFilters() {
    _selectedCategory = 'All';
    _searchQuery = '';
    _selectedCity = '';
    _minBudget = null;
    _maxBudget = null;
    _sortBy = 'newest';
    fetchAvailableJobs();
  }

  Future<void> fetchAvailableJobs() async {
    _isLoadingJobs = true;
    notifyListeners();

    try {
      _availableJobs = await _jobRepository.fetchAvailableJobs(
        category: _selectedCategory == 'All' ? null : _selectedCategory,
        searchQuery: _searchQuery,
        city: _selectedCity,
        minBudget: _minBudget,
        maxBudget: _maxBudget,
        sortBy: _sortBy,
      );
      _isLoadingJobs = false;
      notifyListeners();
    } catch (e) {
      _isLoadingJobs = false;
      notifyListeners();
    }
  }
}

