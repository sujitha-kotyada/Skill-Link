import 'package:flutter/material.dart';
import '../models/worker_model.dart';
import '../repositories/saved_workers_repository.dart';
import '../repositories/worker_repository.dart';

class CustomerProvider extends ChangeNotifier {
  final WorkerRepository _workerRepository;
  final SavedWorkersRepository _savedWorkersRepository;

  // Search & Filters for Find Workers
  String _selectedCategory = 'All';
  String _searchQuery = '';
  String _selectedCity = '';
  double? _maxRate;
  double? _minRating;
  String _sortBy = 'rating_desc';

  List<WorkerModel> _workers = [];
  List<WorkerModel> _savedWorkers = [];
  bool _isLoadingWorkers = false;
  bool _isLoadingSavedWorkers = false;
  String? _errorMessage;

  CustomerProvider({
    WorkerRepository? workerRepository,
    SavedWorkersRepository? savedWorkersRepository,
  })  : _workerRepository = workerRepository ?? WorkerRepository(),
        _savedWorkersRepository = savedWorkersRepository ?? SavedWorkersRepository();

  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  String get selectedCity => _selectedCity;
  double? get maxRate => _maxRate;
  double? get minRating => _minRating;
  String get sortBy => _sortBy;

  List<WorkerModel> get workers => _workers;
  List<WorkerModel> get savedWorkers => _savedWorkers;
  bool get isLoadingWorkers => _isLoadingWorkers;
  bool get isLoadingSavedWorkers => _isLoadingSavedWorkers;
  String? get errorMessage => _errorMessage;

  void setCategory(String category) {
    _selectedCategory = category;
    fetchWorkers();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    fetchWorkers();
  }

  void setCity(String city) {
    _selectedCity = city;
    fetchWorkers();
  }

  void setFilters({
    String? category,
    String? city,
    double? maxRate,
    double? minRating,
    String? sortBy,
  }) {
    if (category != null) _selectedCategory = category;
    if (city != null) _selectedCity = city;
    _maxRate = maxRate;
    _minRating = minRating;
    if (sortBy != null) _sortBy = sortBy;
    fetchWorkers();
  }

  void clearFilters() {
    _selectedCategory = 'All';
    _searchQuery = '';
    _selectedCity = '';
    _maxRate = null;
    _minRating = null;
    _sortBy = 'rating_desc';
    fetchWorkers();
  }

  Future<void> fetchWorkers() async {
    _isLoadingWorkers = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _workers = await _workerRepository.fetchWorkers(
        category: _selectedCategory == 'All' ? null : _selectedCategory,
        searchQuery: _searchQuery,
        city: _selectedCity,
        maxRate: _maxRate,
        minRating: _minRating,
        sortBy: _sortBy,
      );
      _isLoadingWorkers = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load workers: $e';
      _isLoadingWorkers = false;
      notifyListeners();
    }
  }

  Future<void> loadSavedWorkers(String customerId) async {
    _isLoadingSavedWorkers = true;
    notifyListeners();

    try {
      _savedWorkers = await _savedWorkersRepository.fetchSavedWorkers(customerId);
      _isLoadingSavedWorkers = false;
      notifyListeners();
    } catch (e) {
      _isLoadingSavedWorkers = false;
      notifyListeners();
    }
  }

  Future<void> toggleSaveWorker({
    required String customerId,
    required String workerId,
  }) async {
    try {
      await _savedWorkersRepository.toggleSaveWorker(
        customerId: customerId,
        workerId: workerId,
      );
      await loadSavedWorkers(customerId);
    } catch (e) {
      debugPrint('Error toggling saved worker: $e');
    }
  }

  bool isWorkerSaved(String workerId) {
    return _savedWorkers.any((w) => w.uid == workerId);
  }
}
