import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:expense_tracking_desktop_app/theme/app_theme.dart';
import 'package:expense_tracking_desktop_app/database/app_database.dart';
import 'package:expense_tracking_desktop_app/routes/router.dart' as app_router;
import 'package:expense_tracking_desktop_app/providers/app_providers.dart';
import 'package:expense_tracking_desktop_app/features/settings/providers/theme_provider.dart';
import 'package:expense_tracking_desktop_app/services/connectivity_service.dart';
import 'package:expense_tracking_desktop_app/services/error_reporting_service.dart';

class ExpenseTrackerApp extends StatelessWidget {
  final AppDatabase database;
  final ConnectivityService connectivityService;
  final ErrorReportingService errorReportingService;

  const ExpenseTrackerApp({
    super.key,
    required this.database,
    required this.connectivityService,
    required this.errorReportingService,
  });

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(database),
        connectivityServiceProvider.overrideWithValue(connectivityService),
        errorReportingServiceProvider.overrideWithValue(errorReportingService),
      ],
      child: const _AppConsumer(),
    );
  }
}

class _AppConsumer extends ConsumerStatefulWidget {
  const _AppConsumer();

  @override
  ConsumerState<_AppConsumer> createState() => _AppConsumerState();
}

class _AppConsumerState extends ConsumerState<_AppConsumer> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    // Create router once to avoid rebuilding the navigation tree every frame.
    _router = app_router.createRouter();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp.router(
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
      title: 'ExpenseTracker',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
    );
  }
}
