import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:expense_tracking_desktop_app/services/supabase_service.dart';
import '../models/employee_model.dart';
import 'audit_log_repository.dart';

class EmployeeRepository {
  final SupabaseService _supabaseService;
  final AuditLogRepository _auditLogRepository;

  EmployeeRepository(this._supabaseService, this._auditLogRepository);

  SupabaseClient get _client => _supabaseService.client;
  User? get _currentUser => _supabaseService.currentUser;

  Future<String> _getCurrentOrgId() async {
    if (_currentUser == null) {
      throw Exception('User not authenticated');
    }
    final profile = await _client
        .from('user_profiles')
        .select('organization_id')
        .eq('id', _currentUser!.id)
        .single();
    final orgId = profile['organization_id'] as String?;
    if (orgId == null) {
      throw Exception('User has no organization');
    }
    return orgId;
  }

  Future<List<Employee>> getAllEmployees() async {
    try {
      final orgId = await _getCurrentOrgId();
      final response = await _client
          .from('user_profiles')
          .select()
          .eq('organization_id', orgId)
          .eq('role', 'employee')
          .order('full_name');

      final employees = (response as List)
          .map((json) => Employee.fromJson(json as Map<String, dynamic>))
          .toList();
      return employees;
    } catch (e) {
      rethrow;
    }
  }

  Future<Employee?> getEmployeeById(String id) async {
    final orgId = await _getCurrentOrgId();

    try {
      final response = await _client
          .from('user_profiles')
          .select()
          .eq('id', id)
          .eq('organization_id', orgId)
          .single();

      return Employee.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  Future<List<Employee>> getEmployeesByDepartment(String department) async {
    final orgId = await _getCurrentOrgId();

    final response = await _client
        .from('user_profiles')
        .select()
        .eq('organization_id', orgId)
        .eq('role', 'employee')
        .eq('settings->>department', department)
        .order('full_name');

    return (response as List)
        .map((json) => Employee.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<Employee>> getEmployeesByStatus(EmployeeStatus status) async {
    final orgId = await _getCurrentOrgId();

    final dbStatus = status == EmployeeStatus.active ? 'active' : 'suspended';

    final response = await _client
        .from('user_profiles')
        .select()
        .eq('organization_id', orgId)
        .eq('role', 'employee')
        .eq('status', dbStatus)
        .order('full_name');

    return (response as List)
        .map((json) => Employee.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<String>> getAllDepartments() async {
    final orgId = await _getCurrentOrgId();

    final response = await _client
        .from('user_profiles')
        .select('settings')
        .eq('organization_id', orgId)
        .eq('role', 'employee');

    final departments = (response as List)
        .map((item) {
          final rawSettings = item['settings'];
          final settings = rawSettings is Map ? rawSettings as Map<String, dynamic> : <String, dynamic>{};
          return settings['department'] as String? ?? 'General';
        })
        .toSet()
        .toList();
    departments.sort();
    return departments;
  }

  Future<Map<EmployeeStatus, int>> getEmployeeCountByStatus() async {
    final orgId = await _getCurrentOrgId();

    final response = await _client
        .from('user_profiles')
        .select('status')
        .eq('organization_id', orgId)
        .eq('role', 'employee');

    final counts = <EmployeeStatus, int>{
      EmployeeStatus.active: 0,
      EmployeeStatus.suspended: 0,
    };

    for (final item in response as List) {
      final status = _parseStatus(item['status'] as String?);
      counts[status] = (counts[status] ?? 0) + 1;
    }

    return counts;
  }

  Future<void> addEmployee(Employee employee) async {
    try {
      final orgId = await _getCurrentOrgId();

      final employeeData = {
        'email': employee.email,
        'full_name': employee.name,
        'role': 'employee',
        'department': employee.department,
        'phone': employee.phone,
        'hire_date': employee.hireDate.toIso8601String(),
        'status': 'active',
        'organization_id': orgId,
      };

      final result = await _supabaseService.addEmployee(
        email: employee.email,
        password: 'TempPassword123!',
        fullName: employee.name,
        organizationId: orgId,
      );

      if (result['success'] != true) {
        throw Exception(result['message']);
      }

      final userId = result['user_id'] as String;

      await _client.from('user_profiles').update({
        'settings': {'department': employee.department},
        'phone': employee.phone,
        'hire_date': employee.hireDate.toIso8601String(),
      }).eq('id', userId);

      await _auditLogRepository.createAuditLog(
        organizationId: orgId,
        action: 'ADD_EMPLOYEE',
        tableName: 'user_profiles',
        recordId: null,
        newData: employeeData,
        description: 'Added employee: ${employee.name}',
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateEmployee(Employee employee) async {
    final orgId = await _getCurrentOrgId();

    await _client
        .from('user_profiles')
        .update(employee.toJson())
        .eq('id', employee.id)
        .eq('organization_id', orgId);
  }

  Future<void> suspendEmployee(String employeeId) async {
    final orgId = await _getCurrentOrgId();

    final oldEmployee = await _client
        .from('user_profiles')
        .select()
        .eq('id', employeeId)
        .eq('organization_id', orgId)
        .single();

    await _client
        .from('user_profiles')
        .update({
          'status': 'suspended',
        })
        .eq('id', employeeId)
        .eq('organization_id', orgId);

    await _auditLogRepository.createAuditLog(
      organizationId: orgId,
      action: 'SUSPEND_EMPLOYEE',
      tableName: 'user_profiles',
      recordId: null,
      oldData: {
        'status': oldEmployee['status'],
      },
      newData: {'status': 'suspended'},
      description: 'Suspended employee: ${oldEmployee['full_name']}',
    );
  }

  Future<void> activateEmployee(String employeeId) async {
    final orgId = await _getCurrentOrgId();

    final oldEmployee = await _client
        .from('user_profiles')
        .select()
        .eq('id', employeeId)
        .eq('organization_id', orgId)
        .single();

    await _client
        .from('user_profiles')
        .update({
          'status': 'active',
        })
        .eq('id', employeeId)
        .eq('organization_id', orgId);

    await _auditLogRepository.createAuditLog(
      organizationId: orgId,
      action: 'ACTIVATE_EMPLOYEE',
      tableName: 'user_profiles',
      recordId: null,
      oldData: {
        'status': oldEmployee['status'],
      },
      newData: {'status': 'active'},
      description: 'Activated employee: ${oldEmployee['full_name']}',
    );
  }

  Future<void> removeEmployee(String employeeId) async {
    final orgId = await _getCurrentOrgId();

    final oldEmployee = await _client
        .from('user_profiles')
        .select()
        .eq('id', employeeId)
        .eq('organization_id', orgId)
        .single();

    await _client
        .from('user_profiles')
        .delete()
        .eq('id', employeeId)
        .eq('organization_id', orgId);

    await _auditLogRepository.createAuditLog(
      organizationId: orgId,
      action: 'REMOVE_EMPLOYEE',
      tableName: 'user_profiles',
      recordId: null,
      oldData: oldEmployee,
      description: 'Removed employee: ${oldEmployee['full_name']}',
    );
  }

  EmployeeStatus _parseStatus(String? status) {
    switch (status) {
      case 'active':
        return EmployeeStatus.active;
      case 'suspended':
        return EmployeeStatus.suspended;
      default:
        return EmployeeStatus.active;
    }
  }
}
