# Logging and Error Reporting Implementation

## Overview

Comprehensive logging and error reporting system implemented across the expense tracking application with file-based persistence, multiple log levels, error tracking with statistics, and automatic cleanup.

## Implementation Date

Completed: [Current Session]

## Components Added

### 1. Logger Package

- **Package**: `logger: ^2.0.2+1`
- **Location**: Added to `pubspec.yaml`
- **Purpose**: Professional logging library with file output support

### 2. LoggerService

- **File**: `lib/services/logger_service.dart`
- **Pattern**: Singleton
- **Features**:
  - Multiple output destinations (Console + File)
  - Log levels: debug, info, warning, error, fatal
  - File rotation with 7-day retention
  - Pretty formatting with colors, emojis, timestamps
  - Emergency fallback to console-only if file initialization fails
  - Automatic log file cleanup

**Log File Locations**:

- Path: `documents/logs/app_log_TIMESTAMP.txt`
- Format: Pretty-printed with timestamps
- Retention: 7 days (configurable)

**Usage Example**:

```dart
final _logger = LoggerService.instance;

// Debug logging
_logger.debug('CategoryDao: getAllCategories called');

// Info logging
_logger.info('CategoryDao: Retrieved ${result.length} categories');

// Warning logging
_logger.warning('CategoryDao: Category not found with id=$id');

// Error logging
_logger.error('CategoryDao: getAllCategories failed', error: e, stackTrace: stackTrace);

// Fatal logging
_logger.fatal('Application initialization failed', error: e, stackTrace: stackTrace);
```

### 3. ErrorReportingService

- **File**: `lib/services/error_reporting_service.dart`
- **Pattern**: ChangeNotifier
- **Features**:
  - Error severity levels (low, medium, high, critical)
  - Full error context capture (timestamp, stackTrace, userId, screenName, custom context)
  - Error history tracking (max 100 items)
  - Specialized reporting methods for different error types
  - Error statistics generation
  - Export functionality
  - Reactive UI updates via ChangeNotifier

**Error Report Structure**:

```dart
class ErrorReport {
  final DateTime timestamp;
  final String error;
  final String? stackTrace;
  final ErrorSeverity severity;
  final String? userId;
  final String? screenName;
  final Map<String, dynamic> context;
  final bool isHandled;
}
```

**Specialized Reporting Methods**:

- `reportDatabaseError(operation, error, ...)`
- `reportUIError(screen, action, error, ...)`
- `reportBusinessLogicError(operation, error, ...)`
- `reportValidationError(field, message, ...)`

**Error File Locations**:

- Reports: `documents/error_reports/errors_TIMESTAMP.json`
- Exports: `documents/exports/error_export_TIMESTAMP.txt`

**Usage Example**:

```dart
await _errorReporting.reportBusinessLogicError(
  'createExpense',
  e,
  stackTrace: stackTrace,
  context: {
    'categoryId': categoryId.toString(),
    'amount': amount.toString(),
  },
);

// Statistics
final stats = await _errorReporting.getErrorStatistics();
// Returns counts by severity, by screen, handled vs unhandled

// Export
final exportPath = await _errorReporting.exportErrorHistory();
```

## Integration Points

### 1. Main Application (`lib/main.dart`)

**Initialization Sequence**:

```dart
void main() async {
  // 1. Initialize LoggerService first
  await LoggerService.instance.initialize();
  final logger = LoggerService.instance;

  // 2. Initialize ErrorReportingService
  final errorReporting = ErrorReportingService(logger);
  await errorReporting.initialize();

  // 3. Clean old logs
  await logger.cleanOldLogs(keepDays: 7);

  // 4. Enhanced error handling with logging and error reporting
  FlutterError.onError = (FlutterErrorDetails details) {
    logger.fatal('Flutter error', error: details.exception, stackTrace: details.stack);
    errorReporting.reportError(
      details.exception.toString(),
      severity: ErrorSeverity.critical,
      stackTrace: details.stack?.toString(),
      context: {'source': 'FlutterError.onError'},
    );
  };

  // 5. Start app with error reporting service
  runApp(ExpenseTrackerApp(errorReportingService: errorReporting));
}
```

### 2. Dependency Injection (`lib/providers/app_providers.dart`)

**Providers Added**:

```dart
// Logger service provider
final loggerServiceProvider = Provider<LoggerService>((ref) {
  return LoggerService.instance;
});

// Error reporting service provider (override required in app.dart)
final errorReportingServiceProvider = Provider<ErrorReportingService>((ref) {
  throw UnimplementedError('ErrorReportingService must be overridden');
});

// ExpenseService provider (updated with error reporting)
final expenseServiceProvider = Provider<IExpenseService>((ref) {
  final database = ref.watch(databaseInterfaceProvider);
  final expenseRepository = ref.watch(expenseRepositoryProvider);
  final categoryRepository = ref.watch(categoryRepositoryProvider);
  final errorReporting = ref.watch(errorReportingServiceProvider);
  return ExpenseService(
    expenseRepository,
    categoryRepository,
    categoryRepository,
    database,
    errorReporting, // ← Added
  );
});
```

### 3. App Widget (`lib/app.dart`)

**Provider Override**:

```dart
class ExpenseTrackerApp extends ConsumerWidget {
  final ErrorReportingService errorReportingService;

  const ExpenseTrackerApp({
    super.key,
    required this.errorReportingService,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ProviderScope(
      overrides: [
        errorReportingServiceProvider.overrideWithValue(errorReportingService),
      ],
      child: MaterialApp.router(...),
    );
  }
}
```

## Code Coverage

### Data Access Layer (DAOs)

#### CategoryDao (`lib/database/daos/category_dao.dart`)

**Logging Added**:

- ✅ `getAllCategories()`: debug entry, info success, error on failure
- ✅ `getCategoryById()`: debug entry with id, debug/warning on result, error on failure
- ✅ `insertCategory()`: debug entry, warning on validation failures, info on success, error on failure
- ✅ `updateCategoryBudget()`: debug with params, warning on validation/version conflicts, info on success, error on failure
- ✅ `updateCategorySpent()`: debug with params, warning on validation/version conflicts, info on success, error on failure
- ✅ `updateCategory()`: debug entry, warning on validation/version conflicts, info on success, error on failure
- ✅ `deleteCategory()`: debug entry, info/warning on result, error on failure

**Logging Pattern**:

```dart
Future<Category?> getCategoryById(int id) async {
  try {
    _logger.debug('CategoryDao: getCategoryById called with id=$id');
    // ... operation ...
    if (result != null) {
      _logger.debug('CategoryDao: Found category id=$id, name=${result.name}');
    } else {
      _logger.warning('CategoryDao: Category not found with id=$id');
    }
    return result;
  } catch (e, stackTrace) {
    _logger.error('CategoryDao: getCategoryById failed for id=$id', error: e, stackTrace: stackTrace);
    throw Exception('Database error: Failed to get category by id - $e');
  }
}
```

#### ExpenseDao (`lib/database/daos/expense_dao.dart`)

**Logging Added**:

- ✅ `getAllExpenses()`: debug entry, info with count, error on failure
- ✅ `insertExpense()`: debug entry, warning on validation failures, info on success, error on failure
- ✅ `updateExpense()`: debug with id, warning on validation/not found, info on success, error on failure
- ✅ `deleteExpense()`: debug entry, warning on not found, info with amount, error on failure

**Validation Logging**:

- Amount validation: logs warnings for non-positive or too-large amounts
- Date validation: logs warnings for dates too far in future/past

### Service Layer

#### ExpenseService (`lib/features/expenses/services/expense_service.dart`)

**Logging + Error Reporting Added**:

- ✅ `createExpense()`: info on start, debug on transaction/steps, info on success, error + error reporting on failure
- ✅ `updateExpense()`: info on start, debug on category/amount changes, info on success, error + error reporting on failure
- ✅ `deleteExpense()`: info on start, debug on transaction/steps, info on success, error + error reporting on failure

**Enhanced Error Reporting**:

```dart
Future<int> createExpense(ExpensesCompanion expense) async {
  try {
    _logger.info('ExpenseService: Creating expense');
    return await _database.transaction(() async {
      _logger.debug('ExpenseService: Transaction started for createExpense');
      // ... operation ...
      _logger.info('ExpenseService: Expense created successfully - id=$expenseId');
      return expenseId;
    });
  } catch (e, stackTrace) {
    _logger.error('ExpenseService: Failed to create expense', error: e, stackTrace: stackTrace);
    await _errorReporting.reportBusinessLogicError(
      'createExpense',
      e,
      stackTrace: stackTrace,
      context: {
        'categoryId': expense.categoryId.toString(),
        'amount': expense.amount.toString(),
      },
    );
    throw Exception('Failed to create expense: $e');
  }
}
```

## Log Level Usage Guidelines

### Debug Level (`_logger.debug()`)

**When to use**:

- Method entry/exit
- Parameter values
- Internal state changes
- Non-critical operations

**Examples**:

- "CategoryDao: getAllCategories called"
- "ExpenseService: Transaction started for createExpense"
- "CategoryDao: Found category id=5, name=Groceries"

### Info Level (`_logger.info()`)

**When to use**:

- Successful operations
- Important state changes
- Business logic milestones

**Examples**:

- "CategoryDao: Retrieved 15 categories"
- "ExpenseService: Expense created successfully - id=42"
- "CategoryDao: Updated category budget - id=5, new budget=1000.0"

### Warning Level (`_logger.warning()`)

**When to use**:

- Validation failures
- Resource not found
- Concurrent modification detected
- Recoverable errors

**Examples**:

- "CategoryDao: Category not found with id=99"
- "ExpenseDao: Amount validation failed - negative value: -50.0"
- "CategoryDao: updateCategoryBudget concurrent modification detected - id=5, version=3"

### Error Level (`_logger.error()`)

**When to use**:

- Unhandled exceptions
- Database failures
- Critical operation failures

**Examples**:

- "CategoryDao: getAllCategories failed"
- "ExpenseService: Failed to create expense"
- "ExpenseDao: insertExpense failed"

**Always include**: `error: e, stackTrace: stackTrace`

### Fatal Level (`_logger.fatal()`)

**When to use**:

- Application startup failures
- Unrecoverable errors
- Framework-level errors

**Examples**:

- "Application initialization failed"
- "Database connection failed"
- "Flutter framework error"

## Error Reporting Severity Mapping

### ErrorSeverity.low

- Validation errors (user input)
- Expected failures (e.g., not found)
- UI-level errors

### ErrorSeverity.medium

- Business logic errors
- Transaction rollbacks
- UI state errors

### ErrorSeverity.high

- Database errors
- Service layer failures
- Data integrity issues

### ErrorSeverity.critical

- Application crashes
- Flutter framework errors
- Unrecoverable failures

## Testing and Verification

### Log File Verification

1. **Run the application**
2. **Check log files**:
   - Location: `C:\Users\[username]\Documents\logs\`
   - Files: `app_log_YYYY-MM-DD_HH-mm-ss.txt`
3. **Verify content**:
   - Timestamps present
   - Log levels correct
   - Error details captured
   - Stack traces included

### Error Report Verification

1. **Trigger errors** (e.g., validation failures, database errors)
2. **Check error reports**:
   - Location: `C:\Users\[username]\Documents\error_reports\`
   - Files: `errors_YYYY-MM-DD_HH-mm-ss.json`
3. **Verify content**:
   - Error context captured
   - Severity levels correct
   - Stack traces present
   - Custom context included

### Statistics Verification

```dart
// In a debug screen or console:
final stats = await errorReporting.getErrorStatistics();
print(stats); // Should show error counts by severity, screen, etc.
```

## Maintenance

### Log Cleanup

- **Automatic**: LoggerService cleans logs older than 7 days on startup
- **Manual**: Call `await LoggerService.instance.cleanOldLogs(keepDays: N)`
- **Configuration**: Adjust `keepDays` parameter in `main.dart`

### Error History Pruning

- **Automatic**: ErrorReportingService keeps max 100 error reports in memory
- **Manual**: Export error history before clearing: `await errorReporting.exportErrorHistory()`
- **Configuration**: Adjust `_maxErrorHistory` in `error_reporting_service.dart`

## Performance Impact

### LoggerService

- **File I/O**: Asynchronous, non-blocking
- **Console**: Minimal (pretty printing)
- **Memory**: Low (no buffering, direct writes)

### ErrorReportingService

- **Memory**: ~100 error reports × ~2KB = ~200KB max
- **File I/O**: Only on export (manual)
- **ChangeNotifier**: Negligible (only on error)

## Future Enhancements

### Potential Additions

1. **Remote logging**: Send logs to remote server
2. **Log filtering**: UI to filter logs by level, date, source
3. **Error dashboard**: UI to view error statistics and trends
4. **Crash reporting**: Integration with services like Sentry or Crashlytics
5. **Performance logging**: Track operation durations
6. **User analytics**: Track user actions and flows

### Configuration Options

1. **Log levels per module**: Different log levels for DAOs vs Services
2. **Dynamic log levels**: Change log level at runtime
3. **Log file size limits**: Rotate based on size, not just age
4. **Custom formatters**: Per-environment formatters (dev vs prod)

## Summary

### Files Created

- `lib/services/logger_service.dart` (200 lines)
- `lib/services/error_reporting_service.dart` (300+ lines)

### Files Modified

- `pubspec.yaml` (added logger package)
- `lib/main.dart` (initialization and error handling)
- `lib/app.dart` (provider override)
- `lib/providers/app_providers.dart` (service providers)
- `lib/database/daos/category_dao.dart` (comprehensive logging)
- `lib/database/daos/expense_dao.dart` (comprehensive logging)
- `lib/features/expenses/services/expense_service.dart` (logging + error reporting)

### Lines of Code Added

- LoggerService: ~200 lines
- ErrorReportingService: ~300 lines
- DAO logging: ~100 lines (CategoryDao + ExpenseDao)
- Service logging: ~80 lines (ExpenseService)
- Integration: ~30 lines (main.dart, app.dart, providers)
- **Total**: ~710 lines

### Build Status

✅ **flutter pub get**: Success
✅ **dart run build_runner build**: Success (with warnings)
✅ **flutter analyze**: 1 pre-existing error, 106 linter warnings (none from logging)
✅ **Compilation**: All logging code compiles successfully

### Next Steps

1. Run the application and verify log files are created
2. Trigger various operations and check log content
3. Trigger errors and verify error reports
4. Add logging to ViewModels (if desired)
5. Replace remaining `print()` statements with logger calls
6. Test error reporting UI integration
7. Export and review error statistics
