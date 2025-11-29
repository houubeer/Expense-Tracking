import 'package:expense_tracking_desktop_app/features/budget/repositories/i_dashboard_budget_reader.dart';
import 'package:expense_tracking_desktop_app/features/budget/repositories/i_budget_reader.dart';
import 'package:expense_tracking_desktop_app/features/budget/repositories/i_budget_analytics.dart';

/// Complete budget repository interface (ISP - Composition of focused interfaces)
/// Concrete implementations provide all capabilities, clients depend only on what they need
abstract class IBudgetRepository
    implements IDashboardBudgetReader, IBudgetReader, IBudgetAnalytics {}
