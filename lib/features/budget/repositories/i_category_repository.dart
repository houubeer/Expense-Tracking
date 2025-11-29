import 'package:expense_tracking_desktop_app/features/budget/repositories/i_category_reader.dart';
import 'package:expense_tracking_desktop_app/features/budget/repositories/i_category_writer.dart';
import 'package:expense_tracking_desktop_app/features/budget/repositories/i_category_budget_manager.dart';
import 'package:expense_tracking_desktop_app/features/budget/repositories/i_category_query.dart';

/// Complete category repository interface (ISP - Composition of focused interfaces)
/// Concrete implementations provide all capabilities, clients depend only on what they need
abstract class ICategoryRepository
    implements
        ICategoryReader,
        ICategoryWriter,
        ICategoryBudgetManager,
        ICategoryQuery {}
