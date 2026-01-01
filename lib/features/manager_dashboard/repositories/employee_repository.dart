import '../models/employee_model.dart';

/// Repository providing mock employee data
class EmployeeRepository {
  // Mock employee data
  static final List<Employee> _mockEmployees = [
    Employee(
      id: 'emp001',
      name: 'Sarah Johnson',
      role: 'Senior Developer',
      department: 'Engineering',
      email: 'sarah.johnson@company.com',
      phone: '+213 555-0101',
      hireDate: DateTime(2020, 3, 15),
      status: EmployeeStatus.active,
    ),
    Employee(
      id: 'emp002',
      name: 'Michael Chen',
      role: 'Product Manager',
      department: 'Product',
      email: 'michael.chen@company.com',
      phone: '+213 555-0102',
      hireDate: DateTime(2019, 7, 22),
      status: EmployeeStatus.active,
    ),
    Employee(
      id: 'emp003',
      name: 'Emily Rodriguez',
      role: 'UX Designer',
      department: 'Design',
      email: 'emily.rodriguez@company.com',
      phone: '+213 555-0103',
      hireDate: DateTime(2021, 1, 10),
      status: EmployeeStatus.active,
    ),
    Employee(
      id: 'emp004',
      name: 'David Kim',
      role: 'Marketing Specialist',
      department: 'Marketing',
      email: 'david.kim@company.com',
      phone: '+213 555-0104',
      hireDate: DateTime(2021, 9, 5),
      status: EmployeeStatus.active,
    ),
    Employee(
      id: 'emp005',
      name: 'Jessica Williams',
      role: 'Sales Manager',
      department: 'Sales',
      email: 'jessica.williams@company.com',
      phone: '+213 555-0105',
      hireDate: DateTime(2018, 11, 30),
      status: EmployeeStatus.active,
    ),
    Employee(
      id: 'emp006',
      name: 'Robert Taylor',
      role: 'DevOps Engineer',
      department: 'Engineering',
      email: 'robert.taylor@company.com',
      phone: '+213 555-0106',
      hireDate: DateTime(2020, 6, 18),
      status: EmployeeStatus.active,
    ),
    Employee(
      id: 'emp007',
      name: 'Amanda Brown',
      role: 'HR Coordinator',
      department: 'Human Resources',
      email: 'amanda.brown@company.com',
      phone: '+213 555-0107',
      hireDate: DateTime(2022, 2, 14),
      status: EmployeeStatus.active,
    ),
    Employee(
      id: 'emp008',
      name: 'Christopher Lee',
      role: 'Backend Developer',
      department: 'Engineering',
      email: 'christopher.lee@company.com',
      phone: '+213 555-0108',
      hireDate: DateTime(2021, 4, 25),
      status: EmployeeStatus.suspended,
    ),
    Employee(
      id: 'emp009',
      name: 'Maria Garcia',
      role: 'Content Writer',
      department: 'Marketing',
      email: 'maria.garcia@company.com',
      phone: '+213 555-0109',
      hireDate: DateTime(2022, 8, 12),
      status: EmployeeStatus.active,
    ),
    Employee(
      id: 'emp010',
      name: 'James Anderson',
      role: 'QA Engineer',
      department: 'Engineering',
      email: 'james.anderson@company.com',
      phone: '+213 555-0110',
      hireDate: DateTime(2020, 10, 7),
      status: EmployeeStatus.active,
    ),
    Employee(
      id: 'emp011',
      name: 'Lisa Martinez',
      role: 'Financial Analyst',
      department: 'Finance',
      email: 'lisa.martinez@company.com',
      phone: '+213 555-0111',
      hireDate: DateTime(2019, 5, 20),
      status: EmployeeStatus.active,
    ),
    Employee(
      id: 'emp012',
      name: 'Daniel Wilson',
      role: 'Sales Representative',
      department: 'Sales',
      email: 'daniel.wilson@company.com',
      phone: '+213 555-0112',
      hireDate: DateTime(2021, 12, 3),
      status: EmployeeStatus.active,
    ),
  ];

  /// Get all employees
  Future<List<Employee>> getAllEmployees() async {
    // Simulate network delay
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return List.unmodifiable(_mockEmployees);
  }

  /// Get employee by ID
  Future<Employee?> getEmployeeById(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    try {
      return _mockEmployees.firstWhere((emp) => emp.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get employees by department
  Future<List<Employee>> getEmployeesByDepartment(String department) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return _mockEmployees.where((emp) => emp.department == department).toList();
  }

  /// Get employees by status
  Future<List<Employee>> getEmployeesByStatus(EmployeeStatus status) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return _mockEmployees.where((emp) => emp.status == status).toList();
  }

  /// Get all unique departments
  Future<List<String>> getAllDepartments() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return _mockEmployees.map((emp) => emp.department).toSet().toList()..sort();
  }

  /// Get employee count by status
  Future<Map<EmployeeStatus, int>> getEmployeeCountByStatus() async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    final counts = <EmployeeStatus, int>{};
    for (final status in EmployeeStatus.values) {
      counts[status] =
          _mockEmployees.where((emp) => emp.status == status).length;
    }
    return counts;
  }

  /// Add new employee
  Future<void> addEmployee(Employee employee) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    _mockEmployees.add(employee);
  }

  /// Update employee
  Future<void> updateEmployee(Employee employee) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final index = _mockEmployees.indexWhere((emp) => emp.id == employee.id);
    if (index != -1) {
      _mockEmployees[index] = employee;
    }
  }

  /// Suspend employee
  Future<void> suspendEmployee(String employeeId) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final index = _mockEmployees.indexWhere((emp) => emp.id == employeeId);
    if (index != -1) {
      _mockEmployees[index] = _mockEmployees[index].copyWith(
        status: EmployeeStatus.suspended,
      );
    }
  }

  /// Activate employee
  Future<void> activateEmployee(String employeeId) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final index = _mockEmployees.indexWhere((emp) => emp.id == employeeId);
    if (index != -1) {
      _mockEmployees[index] = _mockEmployees[index].copyWith(
        status: EmployeeStatus.active,
      );
    }
  }

  /// Remove employee
  Future<void> removeEmployee(String employeeId) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    _mockEmployees.removeWhere((emp) => emp.id == employeeId);
  }
}
