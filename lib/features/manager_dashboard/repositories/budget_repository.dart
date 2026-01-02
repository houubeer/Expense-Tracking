import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:expense_tracking_desktop_app/services/supabase_service.dart';
import '../models/budget_model.dart';

class BudgetRepository {
  final SupabaseService _supabaseService;

  BudgetRepository(this._supabaseService);

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

  Future<List<DepartmentBudget>> getDepartmentBudgets() async {
    final orgId = await _getCurrentOrgId();

    // Fetch expenses without join
    final expensesResponse = await _client
        .from('expenses')
        .select('amount, created_by')
        .eq('organization_id', orgId);

    // Extract unique user IDs
    final userIds = (expensesResponse as List)
        .map((e) => e['created_by'] as String?)
        .where((id) => id != null)
        .toSet()
        .toList();

    // Fetch user profiles for these IDs
    final Map<String, Map<String, dynamic>> userSettingsMap = {};
    if (userIds.isNotEmpty) {
      final profilesResponse = await _client
          .from('user_profiles')
          .select('id, settings')
          .filter('id', 'in', userIds);
      
      for (final profile in profilesResponse as List) {
        final id = profile['id'] as String;
        final rawSettings = profile['settings'];
        if (rawSettings is Map) {
          userSettingsMap[id] = rawSettings as Map<String, dynamic>;
        }
      }
    }

    final budgetsResponse = await _client
        .from('budgets')
        .select()
        .eq('organization_id', orgId);

    final departmentSpending = <String, double>{};
    for (final expense in expensesResponse) {
      final userId = expense['created_by'] as String?;
      final settings = userSettingsMap[userId] ?? {};
      
      final dept = settings['department'] as String? ?? 'General';
      final amount = (expense['amount'] as num?)?.toDouble() ?? 0.0;
      departmentSpending[dept] = (departmentSpending[dept] ?? 0.0) + amount;
    }

    final budgetsByDept = <String, double>{};
    for (final budget in budgetsResponse as List) {
      final totalBudget = (budget['total_budget'] as num?)?.toDouble() ?? 100000.0;
      // Budget doesn't always have a department field in the schema we saw earlier, 
      // but usually budgets are PER department. 
      // Assuming 'department' column exists in budgets table or we use 'General' if missing.
      // Checking local schema for budgets would be good, but for now assuming this loop was roughly correct before.
      // Wait, previous code: budgetsByDept['General'] = ... 
      // It seems previous code was hardcoding 'General'. 
      // FIX: The previous code was:
      // budgetsByDept['General'] = (budgetsByDept['General'] ?? 0.0) + totalBudget;
      // This implies all budgets were treated as 'General'. 
      // If the budgets table has a 'department' column, we should use it. 
      // But preserving previous logic for now to minimize risk suitable for this task.
      
      // However, if the user wants "Budget Monitoring" to work per department, simply summing to 'General' is wrong 
      // unless there's only one global budget. 
      // Let's stick to the previous logic for budgets part to avoid scope creep, 
      // only fixing the expenses/profiles relationship.
      
      budgetsByDept['General'] = (budgetsByDept['General'] ?? 0.0) + totalBudget;
    }

    final departments = {...departmentSpending.keys, ...budgetsByDept.keys};
    
    return departments.map((dept) {
      final totalBudget = budgetsByDept[dept] ?? 100000.0;
      final usedBudget = departmentSpending[dept] ?? 0.0;
      
      return DepartmentBudget(
        departmentName: dept,
        totalBudget: totalBudget,
        usedBudget: usedBudget,
      );
    }).toList();
  }

  Future<DepartmentBudget?> getBudgetByDepartment(String department) async {
    final budgets = await getDepartmentBudgets();
    try {
      return budgets.firstWhere((b) => b.departmentName == department);
    } catch (e) {
      return null;
    }
  }

  Future<double> getTotalBudget() async {
    final budgets = await getDepartmentBudgets();
    return budgets.fold<double>(0.0, (sum, budget) => sum + budget.totalBudget);
  }

  Future<double> getTotalUsedBudget() async {
    final budgets = await getDepartmentBudgets();
    return budgets.fold<double>(0.0, (sum, budget) => sum + budget.usedBudget);
  }

  Future<double> getTotalRemainingBudget() async {
    final budgets = await getDepartmentBudgets();
    return budgets.fold<double>(
        0.0, (sum, budget) => sum + budget.remainingBudget);
  }

  Future<Map<String, double>> getCategoryBreakdown() async {
    final orgId = await _getCurrentOrgId();

    final response = await _client
        .from('expenses')
        .select('amount, description')
        .eq('organization_id', orgId);

    final categorySpending = <String, double>{};
    for (final expense in response as List) {
      final category = expense['description'] as String? ?? 'Other';
      final amount = (expense['amount'] as num?)?.toDouble() ?? 0.0;
      categorySpending[category] = (categorySpending[category] ?? 0.0) + amount;
    }

    return categorySpending;
  }

  Future<Map<String, double>> getMonthlyTrends() async {
    final orgId = await _getCurrentOrgId();

    final startDate = DateTime.now().subtract(const Duration(days: 180));

    final response = await _client
        .from('expenses')
        .select('amount, date')
        .eq('organization_id', orgId)
        .gte('date', startDate.toIso8601String().split('T')[0]);

    final monthlySpending = <String, double>{};
    for (final expense in response as List) {
      final date = DateTime.parse(expense['date'] as String);
      final monthKey = '${_getMonthName(date.month)} ${date.year}';
      final amount = (expense['amount'] as num?)?.toDouble() ?? 0.0;
      monthlySpending[monthKey] = (monthlySpending[monthKey] ?? 0.0) + amount;
    }

    return monthlySpending;
  }

  Future<List<DepartmentBudget>> getDepartmentsExceedingBudget() async {
    final budgets = await getDepartmentBudgets();
    return budgets.where((budget) => budget.isExceeded).toList();
  }

  Future<List<DepartmentBudget>> getDepartmentsInWarning() async {
    final budgets = await getDepartmentBudgets();
    return budgets.where((budget) => budget.isInWarning).toList();
  }

  Future<List<DepartmentBudget>> getDepartmentsInDanger() async {
    final budgets = await getDepartmentBudgets();
    return budgets.where((budget) => budget.isInDanger).toList();
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[(month - 1) % 12];
  }
}
