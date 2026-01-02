import 'dart:async';
import 'package:expense_tracking_desktop_app/features/dashboard/models/manager_model.dart';

/// Repository for managing manager data with in-memory mocked storage
class ManagerRepository {

  ManagerRepository() {
    _initializeMockData();
  }
  final List<Manager> _managers = [];
  final StreamController<List<Manager>> _managersController =
      StreamController<List<Manager>>.broadcast();

  /// Initialize with mock data
  void _initializeMockData() {
    _managers.addAll([
      // Pending managers
      Manager(
        id: 'm1',
        name: 'John Smith',
        email: 'john.smith@techinnovators.com',
        companyId: 'c1',
        companyName: 'Tech Innovators Inc.',
        phone: '+1 (555) 123-4567',
        requestDate: DateTime.now().subtract(const Duration(days: 2)),
        status: ManagerStatus.pending,
      ),
      Manager(
        id: 'm2',
        name: 'Sarah Johnson',
        email: 'sarah.j@globalsolutions.com',
        companyId: 'c2',
        companyName: 'Global Solutions Ltd.',
        phone: '+1 (555) 234-5678',
        requestDate: DateTime.now().subtract(const Duration(days: 5)),
        status: ManagerStatus.pending,
      ),
      Manager(
        id: 'm3',
        name: 'Michael Chen',
        email: 'm.chen@startupventures.com',
        companyId: 'c3',
        companyName: 'StartUp Ventures',
        phone: '+1 (555) 345-6789',
        requestDate: DateTime.now().subtract(const Duration(days: 1)),
        status: ManagerStatus.pending,
      ),
      // Approved managers
      Manager(
        id: 'm4',
        name: 'Emily Davis',
        email: 'emily.davis@techinnovators.com',
        companyId: 'c1',
        companyName: 'Tech Innovators Inc.',
        phone: '+1 (555) 456-7890',
        requestDate: DateTime.now().subtract(const Duration(days: 30)),
        approvalDate: DateTime.now().subtract(const Duration(days: 28)),
        status: ManagerStatus.approved,
      ),
      Manager(
        id: 'm5',
        name: 'Robert Wilson',
        email: 'r.wilson@enterprisecorp.com',
        companyId: 'c4',
        companyName: 'Enterprise Corp',
        phone: '+1 (555) 567-8901',
        requestDate: DateTime.now().subtract(const Duration(days: 60)),
        approvalDate: DateTime.now().subtract(const Duration(days: 58)),
        status: ManagerStatus.approved,
      ),
      Manager(
        id: 'm6',
        name: 'Lisa Anderson',
        email: 'l.anderson@globalsolutions.com',
        companyId: 'c2',
        companyName: 'Global Solutions Ltd.',
        phone: '+1 (555) 678-9012',
        requestDate: DateTime.now().subtract(const Duration(days: 45)),
        approvalDate: DateTime.now().subtract(const Duration(days: 43)),
        status: ManagerStatus.approved,
      ),
      Manager(
        id: 'm7',
        name: 'David Martinez',
        email: 'd.martinez@enterprisecorp.com',
        companyId: 'c4',
        companyName: 'Enterprise Corp',
        phone: '+1 (555) 789-0123',
        requestDate: DateTime.now().subtract(const Duration(days: 90)),
        approvalDate: DateTime.now().subtract(const Duration(days: 88)),
        status: ManagerStatus.approved,
      ),
      // Suspended manager
      Manager(
        id: 'm8',
        name: 'James Taylor',
        email: 'j.taylor@suspendedcompany.com',
        companyId: 'c5',
        companyName: 'Suspended Company LLC',
        phone: '+1 (555) 890-1234',
        requestDate: DateTime.now().subtract(const Duration(days: 120)),
        approvalDate: DateTime.now().subtract(const Duration(days: 118)),
        status: ManagerStatus.suspended,
      ),
    ]);
    _notifyListeners();
  }

  /// Get all managers
  List<Manager> getAll() {
    return List.unmodifiable(_managers);
  }

  /// Watch all managers (stream)
  Stream<List<Manager>> watchAll() {
    return _managersController.stream;
  }

  /// Get manager by ID
  Manager? getById(String id) {
    try {
      return _managers.firstWhere((m) => m.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get pending managers
  List<Manager> getPending() {
    return _managers.where((m) => m.status == ManagerStatus.pending).toList();
  }

  /// Get approved/active managers
  List<Manager> getActive() {
    return _managers.where((m) => m.status == ManagerStatus.approved).toList();
  }

  /// Get suspended managers
  List<Manager> getSuspended() {
    return _managers.where((m) => m.status == ManagerStatus.suspended).toList();
  }

  /// Create new manager
  Future<Manager> create(Manager manager) async {
    _managers.add(manager);
    _notifyListeners();
    return manager;
  }

  /// Update existing manager
  Future<Manager> update(Manager manager) async {
    final index = _managers.indexWhere((m) => m.id == manager.id);
    if (index == -1) {
      throw Exception('Manager not found');
    }
    _managers[index] = manager;
    _notifyListeners();
    return manager;
  }

  /// Delete manager
  Future<void> delete(String id) async {
    _managers.removeWhere((m) => m.id == id);
    _notifyListeners();
  }

  /// Search managers by name or email
  List<Manager> search(String query) {
    if (query.isEmpty) return getAll();
    final lowerQuery = query.toLowerCase();
    return _managers
        .where((m) =>
            m.name.toLowerCase().contains(lowerQuery) ||
            m.email.toLowerCase().contains(lowerQuery),)
        .toList();
  }

  /// Filter managers by status
  List<Manager> filterByStatus(ManagerStatus status) {
    return _managers.where((m) => m.status == status).toList();
  }

  /// Get total managers count
  int getTotalCount() {
    return _managers.length;
  }

  /// Get pending approvals count
  int getPendingCount() {
    return _managers.where((m) => m.status == ManagerStatus.pending).length;
  }

  /// Get active managers count
  int getActiveCount() {
    return _managers.where((m) => m.status == ManagerStatus.approved).length;
  }

  /// Notify listeners of changes
  void _notifyListeners() {
    _managersController.add(List.unmodifiable(_managers));
  }

  /// Dispose resources
  void dispose() {
    _managersController.close();
  }
}
