import 'package:flutter/foundation.dart';
import 'package:expense_tracking_desktop_app/features/dashboard/models/company_model.dart';
import 'package:expense_tracking_desktop_app/features/dashboard/repositories/company_repository.dart';
import 'package:expense_tracking_desktop_app/features/dashboard/repositories/subscription_repository.dart';

/// ViewModel for Company Management
/// Manages company list, search, filtering, and CRUD operations
class CompanyManagementViewModel extends ChangeNotifier {
  final CompanyRepository _companyRepository;
  final SubscriptionRepository _subscriptionRepository;

  // State properties
  List<Company> _companies = [];
  Company? _selectedCompany;
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  CompanyStatus? _statusFilter;

  CompanyManagementViewModel({
    required CompanyRepository companyRepository,
    required SubscriptionRepository subscriptionRepository,
  })  : _companyRepository = companyRepository,
        _subscriptionRepository = subscriptionRepository {
    loadCompanies();
  }

  // Getters
  List<Company> get companies => _companies;
  Company? get selectedCompany => _selectedCompany;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  CompanyStatus? get statusFilter => _statusFilter;

  /// Load all companies
  Future<void> loadCompanies() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _companies = _companyRepository.getAll();
      _applyFilters();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Search companies by name
  void searchCompanies(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  /// Filter companies by status
  void filterByStatus(CompanyStatus? status) {
    _statusFilter = status;
    _applyFilters();
    notifyListeners();
  }

  /// Apply search and filter
  void _applyFilters() {
    var filtered = _companyRepository.getAll();

    // Apply search
    if (_searchQuery.isNotEmpty) {
      filtered = _companyRepository.search(_searchQuery);
    }

    // Apply status filter
    if (_statusFilter != null) {
      filtered = filtered.where((c) => c.status == _statusFilter).toList();
    }

    _companies = filtered;
  }

  /// Clear all filters
  void clearFilters() {
    _searchQuery = '';
    _statusFilter = null;
    _applyFilters();
    notifyListeners();
  }

  /// Select a company
  void selectCompany(Company company) {
    _selectedCompany = company;
    notifyListeners();
  }

  /// Suspend a company
  Future<void> suspendCompany(String companyId) async {
    try {
      final company = _companyRepository.getById(companyId);
      if (company == null) {
        throw Exception('Company not found');
      }

      final updatedCompany = company.copyWith(status: CompanyStatus.suspended);
      await _companyRepository.update(updatedCompany);
      await loadCompanies();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Activate a company
  Future<void> activateCompany(String companyId) async {
    try {
      final company = _companyRepository.getById(companyId);
      if (company == null) {
        throw Exception('Company not found');
      }

      final updatedCompany = company.copyWith(status: CompanyStatus.active);
      await _companyRepository.update(updatedCompany);
      await loadCompanies();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Delete a company
  Future<void> deleteCompany(String companyId) async {
    try {
      await _companyRepository.delete(companyId);
      
      // Also delete associated subscription
      final subscription = _subscriptionRepository.getByCompanyId(companyId);
      if (subscription != null) {
        await _subscriptionRepository.delete(subscription.id);
      }
      
      await loadCompanies();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Get company by ID
  Company? getCompanyById(String id) {
    return _companyRepository.getById(id);
  }

  /// Get subscription for a company
  dynamic getCompanySubscription(String companyId) {
    return _subscriptionRepository.getByCompanyId(companyId);
  }
}
