import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart' show Value;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../database/app_database.dart';
import '../database/daos/sync_queue_dao.dart';
import 'supabase_service.dart';
import 'logger_service.dart';

/// Sync status enum for tracking sync state
enum SyncStatus {
  idle,
  syncing,
  error,
  offline,
}

/// Sync Service - Handles offline-first synchronization with Supabase
///
/// Features:
/// - Background sync with connectivity monitoring
/// - Queue-based operations for offline changes
/// - Last-write-wins conflict resolution
/// - Automatic retry with exponential backoff
class SyncService {
  final AppDatabase _database;
  final SupabaseService _supabaseService;
  final SyncQueueDao _syncQueueDao;
  final LoggerService _logger;
  final Uuid _uuid = const Uuid();

  // Connectivity monitoring
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _isOnline = false;

  // Sync state
  SyncStatus _status = SyncStatus.idle;
  final _statusController = StreamController<SyncStatus>.broadcast();
  Stream<SyncStatus> get statusStream => _statusController.stream;
  SyncStatus get status => _status;

  // Sync timer for periodic background sync
  Timer? _syncTimer;
  static const Duration _syncInterval = Duration(minutes: 5);

  // Real-time subscriptions
  RealtimeChannel? _categoriesChannel;
  RealtimeChannel? _expensesChannel;

  SyncService({
    required AppDatabase database,
    required SupabaseService supabaseService,
    required LoggerService logger,
  })  : _database = database,
        _supabaseService = supabaseService,
        _syncQueueDao = SyncQueueDao(database),
        _logger = logger;

  /// Initialize the sync service
  Future<void> initialize() async {
    _logger.info('SyncService: Initializing...');

    // Check initial connectivity
    final results = await Connectivity().checkConnectivity();
    _isOnline = !results.contains(ConnectivityResult.none);
    _updateStatus(_isOnline ? SyncStatus.idle : SyncStatus.offline);

    // Start listening to connectivity changes
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
          _handleConnectivityChange,
        );

    // If online and authenticated, start sync
    if (_isOnline && _supabaseService.isAuthenticated) {
      await _performFullSync();
      _startPeriodicSync();
      _setupRealtimeSubscriptions();
    }

    _logger.info('SyncService: Initialized. Online: $_isOnline');
  }

  /// Handle connectivity changes
  void _handleConnectivityChange(List<ConnectivityResult> results) {
    final wasOnline = _isOnline;
    _isOnline = !results.contains(ConnectivityResult.none);

    _logger.info('SyncService: Connectivity changed. Online: $_isOnline');

    if (_isOnline && !wasOnline) {
      // Coming back online
      _updateStatus(SyncStatus.idle);
      if (_supabaseService.isAuthenticated) {
        _performFullSync();
        _startPeriodicSync();
        _setupRealtimeSubscriptions();
      }
    } else if (!_isOnline && wasOnline) {
      // Going offline
      _updateStatus(SyncStatus.offline);
      _stopPeriodicSync();
      _cancelRealtimeSubscriptions();
    }
  }

  /// Update sync status
  void _updateStatus(SyncStatus status) {
    _status = status;
    _statusController.add(status);
  }

  // ==================== Queue Operations ====================

  /// Add a category operation to sync queue
  Future<void> queueCategoryChange({
    required int localId,
    required String operation,
    required Map<String, dynamic> data,
  }) async {
    final syncId = _uuid.v4();
    await _syncQueueDao.addToQueue(
      syncId: syncId,
      targetTable: 'categories',
      recordId: localId,
      operation: operation,
      payload: jsonEncode(data),
    );

    _logger
        .debug('SyncService: Queued category $operation for local ID $localId');

    // If online, try to sync immediately
    if (_isOnline && _supabaseService.isAuthenticated) {
      _processPendingQueue();
    }
  }

  /// Add an expense operation to sync queue
  Future<void> queueExpenseChange({
    required int localId,
    required String operation,
    required Map<String, dynamic> data,
  }) async {
    final syncId = _uuid.v4();
    await _syncQueueDao.addToQueue(
      syncId: syncId,
      targetTable: 'expenses',
      recordId: localId,
      operation: operation,
      payload: jsonEncode(data),
    );

    _logger
        .debug('SyncService: Queued expense $operation for local ID $localId');

    // If online, try to sync immediately
    if (_isOnline && _supabaseService.isAuthenticated) {
      _processPendingQueue();
    }
  }

  // ==================== Sync Operations ====================

  /// Perform a full sync (pull then push)
  Future<void> _performFullSync() async {
    if (!_isOnline || !_supabaseService.isAuthenticated) return;

    try {
      _updateStatus(SyncStatus.syncing);
      _logger.info('SyncService: Starting full sync...');

      // Pull changes from server first
      await _pullChanges();

      // Then push local changes
      await _processPendingQueue();

      _updateStatus(SyncStatus.idle);
      _logger.info('SyncService: Full sync completed');
    } catch (e, stack) {
      _logger.error('SyncService: Full sync failed',
          error: e, stackTrace: stack);
      _updateStatus(SyncStatus.error);
    }
  }

  /// Pull changes from server
  Future<void> _pullChanges() async {
    if (!_supabaseService.isAuthenticated) return;

    try {
      _logger.debug('SyncService: Pulling changes from server...');

      // Get last sync time for categories
      final lastCategorySync = await _getLastSyncTime('categories');
      await _pullCategories(lastCategorySync);

      // Get last sync time for expenses
      final lastExpenseSync = await _getLastSyncTime('expenses');
      await _pullExpenses(lastExpenseSync);

      _logger.debug('SyncService: Pull completed');
    } catch (e, stack) {
      _logger.error('SyncService: Pull failed', error: e, stackTrace: stack);
      rethrow;
    }
  }

  /// Get last sync time for a table
  Future<DateTime?> _getLastSyncTime(String tableName) async {
    // Query local database for max synced_at for this table
    // For now, return null to do full pull (can optimize later)
    return null;
  }

  /// Pull categories from server
  Future<void> _pullCategories(DateTime? since) async {
    try {
      final serverCategories = await _supabaseService.getCategories();

      for (final serverCat in serverCategories) {
        // Check if we have this category locally by server ID
        final localCat =
            await _findLocalCategoryByServerId(serverCat['id'] as String);

        if (localCat == null) {
          // New category from server - insert locally
          await _insertCategoryFromServer(serverCat);
        } else {
          // Existing category - check for conflicts using version
          final serverVersion = serverCat['version'] as int? ?? 1;
          final localVersion = localCat.version;
          final serverUpdated =
              DateTime.parse(serverCat['updated_at'] as String);

          // Last-write-wins: server has newer version or later update time
          if (serverVersion > localVersion ||
              (localCat.syncedAt != null &&
                  serverUpdated.isAfter(localCat.syncedAt!))) {
            await _updateCategoryFromServer(localCat.id, serverCat);
          }
        }
      }
    } catch (e, stack) {
      _logger.error('SyncService: Pull categories failed',
          error: e, stackTrace: stack);
      rethrow;
    }
  }

  /// Pull expenses from server
  Future<void> _pullExpenses(DateTime? since) async {
    try {
      final serverExpenses = await _supabaseService.getExpenses();

      for (final serverExp in serverExpenses) {
        // Check if we have this expense locally by server ID
        final localExp =
            await _findLocalExpenseByServerId(serverExp['id'] as String);

        if (localExp == null) {
          // New expense from server - insert locally
          await _insertExpenseFromServer(serverExp);
        } else {
          // Existing expense - check for conflicts using version
          final serverVersion = serverExp['version'] as int? ?? 1;
          final localVersion = localExp.version;
          final serverUpdated =
              DateTime.parse(serverExp['updated_at'] as String);

          // Last-write-wins: server has newer version
          if (serverVersion > localVersion ||
              (localExp.syncedAt != null &&
                  serverUpdated.isAfter(localExp.syncedAt!))) {
            await _updateExpenseFromServer(localExp.id, serverExp);
          }
        }
      }
    } catch (e, stack) {
      _logger.error('SyncService: Pull expenses failed',
          error: e, stackTrace: stack);
      rethrow;
    }
  }

  /// Process pending queue items
  Future<void> _processPendingQueue() async {
    if (!_isOnline || !_supabaseService.isAuthenticated) return;

    try {
      final pendingItems = await _syncQueueDao.getPendingItems();
      _logger.debug(
          'SyncService: Processing ${pendingItems.length} pending items');

      for (final item in pendingItems) {
        try {
          await _processQueueItem(item);
          await _syncQueueDao.markSynced(item.id);
        } catch (e) {
          _logger.warning(
              'SyncService: Failed to process queue item ${item.id}: $e');
          await _syncQueueDao.markFailed(item.id, e.toString());
        }
      }

      // Also retry failed items
      final retryItems = await _syncQueueDao.getRetryableItems();
      for (final item in retryItems) {
        try {
          await _processQueueItem(item);
          await _syncQueueDao.markSynced(item.id);
        } catch (e) {
          _logger.warning('SyncService: Retry failed for item ${item.id}: $e');
          await _syncQueueDao.markFailed(item.id, e.toString());
        }
      }

      // Cleanup old synced items
      await _syncQueueDao.cleanupSyncedItems();
    } catch (e, stack) {
      _logger.error('SyncService: Queue processing failed',
          error: e, stackTrace: stack);
      rethrow;
    }
  }

  /// Process a single queue item
  Future<void> _processQueueItem(SyncQueueData item) async {
    final payload = jsonDecode(item.payload) as Map<String, dynamic>;

    switch (item.targetTable) {
      case 'categories':
        await _processCategoryQueueItem(item.operation, item.recordId, payload);
        break;
      case 'expenses':
        await _processExpenseQueueItem(item.operation, item.recordId, payload);
        break;
      default:
        _logger.warning('SyncService: Unknown table ${item.targetTable}');
    }
  }

  /// Process category queue item
  Future<void> _processCategoryQueueItem(
    String operation,
    int? localId,
    Map<String, dynamic> payload,
  ) async {
    switch (operation) {
      case 'INSERT':
        final serverId = await _supabaseService.createCategory(
          name: payload['name'] as String,
          icon: payload['icon'] as String,
          color: payload['color'] as String,
        );
        // Update local record with server ID
        if (localId != null && serverId != null) {
          await _updateLocalCategoryServerId(localId, serverId);
        }
        break;
      case 'UPDATE':
        final serverId = payload['server_id'] as String?;
        if (serverId != null) {
          await _supabaseService.updateCategory(
            id: serverId,
            name: payload['name'] as String?,
            icon: payload['icon'] as String?,
            color: payload['color'] as String?,
          );
        }
        break;
      case 'DELETE':
        final serverId = payload['server_id'] as String?;
        if (serverId != null) {
          await _supabaseService.deleteCategory(serverId);
        }
        break;
    }
  }

  /// Process expense queue item
  Future<void> _processExpenseQueueItem(
    String operation,
    int? localId,
    Map<String, dynamic> payload,
  ) async {
    switch (operation) {
      case 'INSERT':
        final serverId = await _supabaseService.createExpense(
          categoryId: payload['category_server_id'] as String,
          amount: (payload['amount'] as num).toDouble(),
          description: payload['description'] as String?,
          expenseDate: DateTime.parse(payload['expense_date'] as String),
          receiptUrl: payload['receipt_url'] as String?,
        );
        // Update local record with server ID
        if (localId != null && serverId != null) {
          await _updateLocalExpenseServerId(localId, serverId);
        }
        break;
      case 'UPDATE':
        final serverId = payload['server_id'] as String?;
        if (serverId != null) {
          await _supabaseService.updateExpense(
            id: serverId,
            categoryId: payload['category_server_id'] as String?,
            amount: payload['amount'] != null
                ? (payload['amount'] as num).toDouble()
                : null,
            description: payload['description'] as String?,
            expenseDate: payload['expense_date'] != null
                ? DateTime.parse(payload['expense_date'] as String)
                : null,
            receiptUrl: payload['receipt_url'] as String?,
          );
        }
        break;
      case 'DELETE':
        final serverId = payload['server_id'] as String?;
        if (serverId != null) {
          await _supabaseService.deleteExpense(serverId);
        }
        break;
    }
  }

  // ==================== Local Database Helpers ====================

  Future<Category?> _findLocalCategoryByServerId(String serverId) async {
    // Query database for category with this server ID
    final serverIdInt = int.tryParse(serverId);
    if (serverIdInt == null) return null;
    final result = await (_database.select(_database.categories)
          ..where((c) => c.serverId.equals(serverIdInt)))
        .getSingleOrNull();
    return result;
  }

  Future<Expense?> _findLocalExpenseByServerId(String serverId) async {
    final serverIdInt = int.tryParse(serverId);
    if (serverIdInt == null) return null;
    final result = await (_database.select(_database.expenses)
          ..where((e) => e.serverId.equals(serverIdInt)))
        .getSingleOrNull();
    return result;
  }

  Future<void> _insertCategoryFromServer(Map<String, dynamic> data) async {
    final colorValue = data['color'];
    final colorInt = colorValue is int
        ? colorValue
        : int.tryParse(colorValue.toString()) ?? 0xFF000000;
    await _database
        .into(_database.categories)
        .insert(CategoriesCompanion.insert(
          name: data['name'] as String,
          iconCodePoint: data['icon'] as String,
          color: colorInt,
          serverId: Value(int.tryParse(data['id'].toString())),
          organizationId: Value(data['organization_id'] as String?),
          userId: Value(data['user_id'] as String?),
          isSynced: const Value(true),
          syncedAt: Value(DateTime.now()),
          version: Value(data['version'] as int? ?? 1),
        ));
  }

  Future<void> _updateCategoryFromServer(
      int localId, Map<String, dynamic> data) async {
    final colorValue = data['color'];
    final colorInt = colorValue is int
        ? colorValue
        : int.tryParse(colorValue.toString()) ?? 0xFF000000;
    await (_database.update(_database.categories)
          ..where((c) => c.id.equals(localId)))
        .write(CategoriesCompanion(
      name: Value(data['name'] as String),
      iconCodePoint: Value(data['icon'] as String),
      color: Value(colorInt),
      isSynced: const Value(true),
      syncedAt: Value(DateTime.now()),
      version: Value(data['version'] as int? ?? 1),
    ));
  }

  Future<void> _insertExpenseFromServer(Map<String, dynamic> data) async {
    // Find local category by server ID
    final categoryServerId = data['category_id'] as String;
    final category = await _findLocalCategoryByServerId(categoryServerId);
    if (category == null) {
      _logger.warning(
          'SyncService: Category not found for expense: $categoryServerId');
      return;
    }

    await _database.into(_database.expenses).insert(ExpensesCompanion.insert(
          categoryId: category.id,
          amount: (data['amount'] as num).toDouble(),
          description: data['description'] as String? ?? '',
          date: DateTime.parse(data['expense_date'] as String),
          serverId: Value(int.tryParse(data['id'].toString())),
          organizationId: Value(data['organization_id'] as String?),
          userId: Value(data['user_id'] as String?),
          receiptUrl: Value(data['receipt_url'] as String?),
          isSynced: const Value(true),
          syncedAt: Value(DateTime.now()),
          version: Value(data['version'] as int? ?? 1),
        ));
  }

  Future<void> _updateExpenseFromServer(
      int localId, Map<String, dynamic> data) async {
    // Find local category by server ID
    int? categoryId;
    final categoryServerId = data['category_id'] as String?;
    if (categoryServerId != null) {
      final category = await _findLocalCategoryByServerId(categoryServerId);
      categoryId = category?.id;
    }

    await (_database.update(_database.expenses)
          ..where((e) => e.id.equals(localId)))
        .write(ExpensesCompanion(
      categoryId: categoryId != null ? Value(categoryId) : const Value.absent(),
      amount: Value((data['amount'] as num).toDouble()),
      description: Value(data['description'] as String? ?? ''),
      date: Value(DateTime.parse(data['expense_date'] as String)),
      receiptUrl: Value(data['receipt_url'] as String?),
      isSynced: const Value(true),
      syncedAt: Value(DateTime.now()),
      version: Value(data['version'] as int? ?? 1),
    ));
  }

  Future<void> _updateLocalCategoryServerId(
      int localId, String serverId) async {
    await (_database.update(_database.categories)
          ..where((c) => c.id.equals(localId)))
        .write(CategoriesCompanion(
      serverId: Value(int.tryParse(serverId)),
      isSynced: const Value(true),
      syncedAt: Value(DateTime.now()),
    ));
  }

  Future<void> _updateLocalExpenseServerId(int localId, String serverId) async {
    await (_database.update(_database.expenses)
          ..where((e) => e.id.equals(localId)))
        .write(ExpensesCompanion(
      serverId: Value(int.tryParse(serverId)),
      isSynced: const Value(true),
      syncedAt: Value(DateTime.now()),
    ));
  }

  // ==================== Periodic Sync ====================

  void _startPeriodicSync() {
    _stopPeriodicSync();
    _syncTimer = Timer.periodic(_syncInterval, (_) {
      if (_isOnline && _supabaseService.isAuthenticated) {
        _performFullSync();
      }
    });
    _logger.debug('SyncService: Started periodic sync');
  }

  void _stopPeriodicSync() {
    _syncTimer?.cancel();
    _syncTimer = null;
    _logger.debug('SyncService: Stopped periodic sync');
  }

  // ==================== Real-time Subscriptions ====================

  Future<void> _setupRealtimeSubscriptions() async {
    _cancelRealtimeSubscriptions();

    try {
      // Get current user's organization ID
      final profile = await _supabaseService.getCurrentUserProfile();
      final orgId = profile?['organization_id'] as String?;
      if (orgId == null) {
        _logger.warning(
            'SyncService: No organization ID found for real-time subscriptions');
        return;
      }

      // Subscribe to categories changes
      _categoriesChannel = _supabaseService.subscribeToCategories(
        organizationId: orgId,
        onInsert: (data) => _handleServerInsert('categories', data),
        onUpdate: (data) => _handleServerUpdate('categories', data),
        onDelete: (data) => _handleServerDelete('categories', data),
      );

      // Subscribe to expenses changes
      _expensesChannel = _supabaseService.subscribeToExpenses(
        organizationId: orgId,
        onInsert: (data) => _handleServerInsert('expenses', data),
        onUpdate: (data) => _handleServerUpdate('expenses', data),
        onDelete: (data) => _handleServerDelete('expenses', data),
      );

      _logger.info('SyncService: Real-time subscriptions set up');
    } catch (e, stack) {
      _logger.error('SyncService: Failed to set up real-time subscriptions',
          error: e, stackTrace: stack);
    }
  }

  void _cancelRealtimeSubscriptions() {
    _categoriesChannel?.unsubscribe();
    _categoriesChannel = null;
    _expensesChannel?.unsubscribe();
    _expensesChannel = null;
  }

  void _handleServerInsert(String table, Map<String, dynamic> data) {
    _logger.debug('SyncService: Real-time INSERT on $table');
    // Trigger a pull to get the new record
    if (table == 'categories') {
      _pullCategories(null);
    } else if (table == 'expenses') {
      _pullExpenses(null);
    }
  }

  void _handleServerUpdate(String table, Map<String, dynamic> data) {
    _logger.debug('SyncService: Real-time UPDATE on $table');
    if (table == 'categories') {
      _pullCategories(null);
    } else if (table == 'expenses') {
      _pullExpenses(null);
    }
  }

  void _handleServerDelete(String table, Map<String, dynamic> data) {
    _logger.debug('SyncService: Real-time DELETE on $table');
    // Handle delete - remove local record with matching server ID
    final serverId = data['id'] as String?;
    if (serverId != null) {
      _handleLocalDelete(table, serverId);
    }
  }

  Future<void> _handleLocalDelete(String table, String serverId) async {
    final serverIdInt = int.tryParse(serverId);
    if (serverIdInt == null) {
      _logger.warning('SyncService: Invalid serverId format: $serverId');
      return;
    }
    try {
      if (table == 'categories') {
        await (_database.delete(_database.categories)
              ..where((c) => c.serverId.equals(serverIdInt)))
            .go();
      } else if (table == 'expenses') {
        await (_database.delete(_database.expenses)
              ..where((e) => e.serverId.equals(serverIdInt)))
            .go();
      }
      _logger.debug(
          'SyncService: Deleted local record for $table with server ID $serverId');
    } catch (e, stack) {
      _logger.error('SyncService: Failed to delete local record',
          error: e, stackTrace: stack);
    }
  }

  // ==================== Public API ====================

  /// Force a full sync
  Future<void> sync() async {
    if (!_isOnline) {
      _logger.warning('SyncService: Cannot sync while offline');
      return;
    }
    await _performFullSync();
  }

  /// Get pending sync count
  Stream<int> get pendingCountStream => _syncQueueDao.watchPendingCount();

  /// Check if online
  bool get isOnline => _isOnline;

  /// Dispose the service
  void dispose() {
    _connectivitySubscription?.cancel();
    _stopPeriodicSync();
    _cancelRealtimeSubscriptions();
    _statusController.close();
    _logger.info('SyncService: Disposed');
  }
}
