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

  List<JobModel> _allOpenJobs = [];
  List<JobModel> _availableJobs = [];
  bool _isLoadingJobs = false;
  int _fetchRequestCounter = 0;

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

  bool get isSearching => _searchQuery.trim().isNotEmpty;
  bool get hasActiveFilters =>
      _selectedCategory != 'All' ||
      _selectedCity.trim().isNotEmpty ||
      (_minBudget != null && _minBudget! > 0) ||
      (_maxBudget != null && _maxBudget! > 0);

  List<JobModel> getRecommendedJobs([WorkerModel? overrideProfile]) {
    final effectiveProfile = overrideProfile ?? _profile;
    if (effectiveProfile == null) return [];
    return _allOpenJobs
        .where((job) => JobRepository.matchesWorkerProfile(job, effectiveProfile))
        .toList();
  }

  bool doesJobMatchProfile(JobModel job, [WorkerModel? overrideProfile]) {
    final effectiveProfile = overrideProfile ?? _profile;
    return JobRepository.matchesWorkerProfile(job, effectiveProfile);
  }

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
    _availableJobs = [];
    fetchAvailableJobs();
  }

  void setJobSearchQuery(String query) {
    if (_searchQuery == query) return;
    _searchQuery = query;
    _availableJobs = [];
    fetchAvailableJobs();
  }

  void clearSearchQuery() {
    if (_searchQuery.isEmpty) return;
    _searchQuery = '';
    _availableJobs = [];
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
    _availableJobs = [];
    fetchAvailableJobs();
  }

  void clearJobFilters() {
    _selectedCategory = 'All';
    _searchQuery = '';
    _selectedCity = '';
    _minBudget = null;
    _maxBudget = null;
    _sortBy = 'newest';
    _availableJobs = [];
    fetchAvailableJobs();
  }

  Future<void> fetchAvailableJobs() async {
    final requestId = ++_fetchRequestCounter;
    _isLoadingJobs = true;
    notifyListeners();

    try {
      final results = await _jobRepository.fetchAvailableJobs(
        category: _selectedCategory == 'All' ? null : _selectedCategory,
        searchQuery: _searchQuery,
        city: _selectedCity,
        minBudget: _minBudget,
        maxBudget: _maxBudget,
        sortBy: _sortBy,
      );
      if (requestId != _fetchRequestCounter) return;
      _availableJobs = results;
      if (!isSearching && !hasActiveFilters) {
        _allOpenJobs = results;
      }
      _isLoadingJobs = false;
      notifyListeners();
    } catch (e) {
      if (requestId != _fetchRequestCounter) return;
      _availableJobs = [];
      _isLoadingJobs = false;
      notifyListeners();
    }
  }

  Future<void> fetchRecommendedJobs() async {
    try {
      final results = await _jobRepository.fetchAvailableJobs(sortBy: 'newest');
      _allOpenJobs = results;
      notifyListeners();
    } catch (_) {}
  }
}

