import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:expense_tracking_desktop_app/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracking_desktop_app/theme/app_theme.dart';
import 'package:expense_tracking_desktop_app/database/app_database.dart';
import 'package:expense_tracking_desktop_app/routes/router.dart' as app_router;
import 'package:expense_tracking_desktop_app/providers/app_providers.dart';
import 'package:expense_tracking_desktop_app/features/settings/providers/theme_provider.dart';
import 'package:expense_tracking_desktop_app/features/settings/providers/locale_provider.dart';
import 'package:expense_tracking_desktop_app/services/connectivity_service.dart';
import 'package:expense_tracking_desktop_app/services/error_reporting_service.dart';

class ExpenseTrackerApp extends StatelessWidget {
  const ExpenseTrackerApp({
    required this.database,
    required this.connectivityService,
    required this.errorReportingService,
    super.key,
  });
  final AppDatabase database;
  final ConnectivityService connectivityService;
  final ErrorReportingService errorReportingService;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        databaseStateProvider.overrideWith((ref) => database),
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
    _router = ref.read(app_router.routerProvider);
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
      title: 'ExpenseTracker',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('fr'),
        Locale('ar'),
      ],
    );
  }
}
