import 'package:expense_tracking_desktop_app/features/dashboard/models/manager_model.dart';
import 'package:expense_tracking_desktop_app/features/dashboard/repositories/manager_repository.dart';
import 'package:expense_tracking_desktop_app/features/manager_dashboard/models/audit_log_model.dart';

/// Service for handling manager approval workflows
/// Contains business logic for approving, rejecting, suspending, and activating managers
class ManagerApprovalService {

  ManagerApprovalService(this._managerRepository);
  final ManagerRepository _managerRepository;
  final List<AuditLog> _auditLogs = [];

  /// Approve a pending manager
  Future<void> approveManager(String managerId) async {
    final manager = _managerRepository.getById(managerId);
    if (manager == null) {
      throw Exception('Manager not found');
    }

    if (manager.status != ManagerStatus.pending) {
      throw Exception('Only pending managers can be approved');
    }

    // Update manager status
    final updatedManager = manager.copyWith(
      status: ManagerStatus.approved,
      approvalDate: DateTime.now(),
    );
    await _managerRepository.update(updatedManager);

    // Create audit log
    _createAuditLog(
      action: 'APPROVE_MANAGER',
      managerName: 'Owner',
      details: 'Approved manager ${manager.name} for ${manager.companyName}',
    );
  }

  /// Reject a pending manager
  Future<void> rejectManager(String managerId, String reason) async {
    final manager = _managerRepository.getById(managerId);
    if (manager == null) {
      throw Exception('Manager not found');
    }

    if (manager.status != ManagerStatus.pending) {
      throw Exception('Only pending managers can be rejected');
    }

    // Update manager status
    final updatedManager = manager.copyWith(
      status: ManagerStatus.rejected,
    );
    await _managerRepository.update(updatedManager);

    // Create audit log
    _createAuditLog(
      action: 'REJECT_MANAGER',
      managerName: 'Owner',
      details: 'Rejected manager ${manager.name} for ${manager.companyName}. Reason: $reason',
    );
  }

  /// Suspend an active manager
  Future<void> suspendManager(String managerId, String reason) async {
    final manager = _managerRepository.getById(managerId);
    if (manager == null) {
      throw Exception('Manager not found');
    }

    if (manager.status != ManagerStatus.approved) {
      throw Exception('Only approved managers can be suspended');
    }

    // Update manager status
    final updatedManager = manager.copyWith(
      status: ManagerStatus.suspended,
    );
    await _managerRepository.update(updatedManager);

    // Create audit log
    _createAuditLog(
      action: 'SUSPEND_MANAGER',
      managerName: 'Owner',
      details: 'Suspended manager ${manager.name} from ${manager.companyName}. Reason: $reason',
    );
  }

  /// Activate a suspended manager
  Future<void> activateManager(String managerId) async {
    final manager = _managerRepository.getById(managerId);
    if (manager == null) {
      throw Exception('Manager not found');
    }

    if (manager.status != ManagerStatus.suspended) {
      throw Exception('Only suspended managers can be activated');
    }

    // Update manager status
    final updatedManager = manager.copyWith(
      status: ManagerStatus.approved,
    );
    await _managerRepository.update(updatedManager);

    // Create audit log
    _createAuditLog(
      action: 'ACTIVATE_MANAGER',
      managerName: 'Owner',
      details: 'Activated manager ${manager.name} for ${manager.companyName}',
    );
  }

  /// Delete a manager
  Future<void> deleteManager(String managerId) async {
    final manager = _managerRepository.getById(managerId);
    if (manager == null) {
      throw Exception('Manager not found');
    }

    await _managerRepository.delete(managerId);

    // Create audit log
    _createAuditLog(
      action: 'DELETE_MANAGER',
      managerName: 'Owner',
      details: 'Deleted manager ${manager.name} from ${manager.companyName}',
    );
  }

  /// Get all audit logs
  List<AuditLog> getAuditLogs() {
    return List.unmodifiable(_auditLogs);
  }

  /// Create an audit log entry
  void _createAuditLog({
    required String action,
    required String managerName,
    required String details,
  }) {
    final log = AuditLog(
      id: 'audit_${DateTime.now().millisecondsSinceEpoch}',
      organizationId: 'owner',
      userId: 'owner',
      userEmail: 'owner@system.com',
      userName: managerName,
      action: action,
      tableName: 'managers',
      description: details,
      createdAt: DateTime.now(),
    );
    _auditLogs.insert(0, log); // Insert at beginning for chronological order
  }
}
