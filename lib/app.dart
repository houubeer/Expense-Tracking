import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracking_desktop_app/constants/colors.dart';
import 'package:expense_tracking_desktop_app/database/app_database.dart';
import 'package:expense_tracking_desktop_app/routes/router.dart' as app_router;

class ExpenseTrackerApp extends StatelessWidget {
  final AppDatabase database;

  const ExpenseTrackerApp({super.key, required this.database});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp.router(
        routerConfig: app_router.createRouter(database),
        debugShowCheckedModeBanner: false,
        title: 'ExpenseTracker',
        theme: ThemeData(
          fontFamily: 'Raleway',
          scaffoldBackgroundColor: AppColors.background,
        ),
      ),
    );
  }
}
