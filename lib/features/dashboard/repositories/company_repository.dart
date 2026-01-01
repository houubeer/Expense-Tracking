import 'dart:async';
import 'package:expense_tracking_desktop_app/features/dashboard/models/company_model.dart';

/// Repository for managing company data with in-memory mocked storage
class CompanyRepository {
  final List<Company> _companies = [];
  final StreamController<List<Company>> _companiesController =
      StreamController<List<Company>>.broadcast();

  CompanyRepository() {
    _initializeMockData();
  }

  /// Initialize with mock data
  void _initializeMockData() {
    _companies.addAll([
      Company(
        id: 'c1',
        name: 'Tech Innovators Inc.',
        managersCount: 3,
        employeesCount: 45,
        subscriptionPlan: 'Enterprise',
        status: CompanyStatus.active,
        createdDate: DateTime(2023, 1, 15),
      ),
      Company(
        id: 'c2',
        name: 'Global Solutions Ltd.',
        managersCount: 2,
        employeesCount: 28,
        subscriptionPlan: 'Premium',
        status: CompanyStatus.active,
        createdDate: DateTime(2023, 3, 22),
      ),
      Company(
        id: 'c3',
        name: 'StartUp Ventures',
        managersCount: 1,
        employeesCount: 12,
        subscriptionPlan: 'Basic',
        status: CompanyStatus.active,
        createdDate: DateTime(2023, 6, 10),
      ),
      Company(
        id: 'c4',
        name: 'Enterprise Corp',
        managersCount: 5,
        employeesCount: 120,
        subscriptionPlan: 'Enterprise',
        status: CompanyStatus.active,
        createdDate: DateTime(2022, 11, 5),
      ),
      Company(
        id: 'c5',
        name: 'Suspended Company LLC',
        managersCount: 1,
        employeesCount: 8,
        subscriptionPlan: 'Basic',
        status: CompanyStatus.suspended,
        createdDate: DateTime(2023, 8, 18),
      ),
    ]);
    _notifyListeners();
  }

  /// Get all companies
  List<Company> getAll() {
    return List.unmodifiable(_companies);
  }

  /// Watch all companies (stream)
  Stream<List<Company>> watchAll() {
    return _companiesController.stream;
  }

  /// Get company by ID
  Company? getById(String id) {
    try {
      return _companies.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Create new company
  Future<Company> create(Company company) async {
    _companies.add(company);
    _notifyListeners();
    return company;
  }

  /// Update existing company
  Future<Company> update(Company company) async {
    final index = _companies.indexWhere((c) => c.id == company.id);
    if (index == -1) {
      throw Exception('Company not found');
    }
    _companies[index] = company;
    _notifyListeners();
    return company;
  }

  /// Delete company
  Future<void> delete(String id) async {
    _companies.removeWhere((c) => c.id == id);
    _notifyListeners();
  }

  /// Search companies by name
  List<Company> search(String query) {
    if (query.isEmpty) return getAll();
    final lowerQuery = query.toLowerCase();
    return _companies
        .where((c) => c.name.toLowerCase().contains(lowerQuery))
        .toList();
  }

  /// Filter companies by status
  List<Company> filterByStatus(CompanyStatus status) {
    return _companies.where((c) => c.status == status).toList();
  }

  /// Get total companies count
  int getTotalCount() {
    return _companies.length;
  }

  /// Get active companies count
  int getActiveCount() {
    return _companies.where((c) => c.status == CompanyStatus.active).length;
  }

  /// Get total employees across all companies
  int getTotalEmployees() {
    return _companies.fold(0, (sum, c) => sum + c.employeesCount);
  }

  /// Get total managers across all companies
  int getTotalManagers() {
    return _companies.fold(0, (sum, c) => sum + c.managersCount);
  }

  /// Notify listeners of changes
  void _notifyListeners() {
    _companiesController.add(List.unmodifiable(_companies));
  }

  /// Dispose resources
  void dispose() {
    _companiesController.close();
  }
}
