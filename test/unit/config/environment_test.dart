import 'package:expense_tracking_desktop_app/config/environment.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EnvironmentConfig', () {
    tearDown(() {
      // Reset to development after each test
      EnvironmentConfig.setEnvironment(Environment.dev);
    });

    test('default environment is development', () {
      expect(EnvironmentConfig.current, Environment.dev);
      expect(EnvironmentConfig.isDevelopment, isTrue);
      expect(EnvironmentConfig.isStaging, isFalse);
      expect(EnvironmentConfig.isProduction, isFalse);
    });

    test('can set environment to staging', () {
      EnvironmentConfig.setEnvironment(Environment.staging);

      expect(EnvironmentConfig.current, Environment.staging);
      expect(EnvironmentConfig.isDevelopment, isFalse);
      expect(EnvironmentConfig.isStaging, isTrue);
      expect(EnvironmentConfig.isProduction, isFalse);
    });

    test('can set environment to production', () {
      EnvironmentConfig.setEnvironment(Environment.production);

      expect(EnvironmentConfig.current, Environment.production);
      expect(EnvironmentConfig.isDevelopment, isFalse);
      expect(EnvironmentConfig.isStaging, isFalse);
      expect(EnvironmentConfig.isProduction, isTrue);
    });

    test('development has correct database path', () {
      EnvironmentConfig.setEnvironment(Environment.dev);
      expect(EnvironmentConfig.databasePath, 'dev_expense_tracker.db');
    });

    test('staging has correct database path', () {
      EnvironmentConfig.setEnvironment(Environment.staging);
      expect(EnvironmentConfig.databasePath, 'staging_expense_tracker.db');
    });

    test('production has correct database path', () {
      EnvironmentConfig.setEnvironment(Environment.production);
      expect(EnvironmentConfig.databasePath, 'expense_tracker.db');
    });

    test('development has debug log level', () {
      EnvironmentConfig.setEnvironment(Environment.dev);
      expect(EnvironmentConfig.logLevel, 'debug');
    });

    test('staging has info log level', () {
      EnvironmentConfig.setEnvironment(Environment.staging);
      expect(EnvironmentConfig.logLevel, 'info');
    });

    test('production has warning log level', () {
      EnvironmentConfig.setEnvironment(Environment.production);
      expect(EnvironmentConfig.logLevel, 'warning');
    });

    test('development retains logs for 3 days', () {
      EnvironmentConfig.setEnvironment(Environment.dev);
      expect(EnvironmentConfig.logRetentionDays, 3);
    });

    test('staging retains logs for 7 days', () {
      EnvironmentConfig.setEnvironment(Environment.staging);
      expect(EnvironmentConfig.logRetentionDays, 7);
    });

    test('production retains logs for 30 days', () {
      EnvironmentConfig.setEnvironment(Environment.production);
      expect(EnvironmentConfig.logRetentionDays, 30);
    });

    test('error reporting disabled in development', () {
      EnvironmentConfig.setEnvironment(Environment.dev);
      expect(EnvironmentConfig.errorReportingEnabled, isFalse);
    });

    test('error reporting enabled in staging', () {
      EnvironmentConfig.setEnvironment(Environment.staging);
      expect(EnvironmentConfig.errorReportingEnabled, isTrue);
    });

    test('error reporting enabled in production', () {
      EnvironmentConfig.setEnvironment(Environment.production);
      expect(EnvironmentConfig.errorReportingEnabled, isTrue);
    });

    test('environment names are correct', () {
      EnvironmentConfig.setEnvironment(Environment.dev);
      expect(EnvironmentConfig.environmentName, 'Development');

      EnvironmentConfig.setEnvironment(Environment.staging);
      expect(EnvironmentConfig.environmentName, 'Staging');

      EnvironmentConfig.setEnvironment(Environment.production);
      expect(EnvironmentConfig.environmentName, 'Production');
    });

    test('database timeout varies by environment', () {
      EnvironmentConfig.setEnvironment(Environment.dev);
      expect(EnvironmentConfig.databaseTimeoutSeconds, 30);

      EnvironmentConfig.setEnvironment(Environment.staging);
      expect(EnvironmentConfig.databaseTimeoutSeconds, 20);

      EnvironmentConfig.setEnvironment(Environment.production);
      expect(EnvironmentConfig.databaseTimeoutSeconds, 15);
    });

    test('debug features enabled only in development', () {
      EnvironmentConfig.setEnvironment(Environment.dev);
      expect(EnvironmentConfig.enableDebugFeatures, isTrue);

      EnvironmentConfig.setEnvironment(Environment.staging);
      expect(EnvironmentConfig.enableDebugFeatures, isFalse);

      EnvironmentConfig.setEnvironment(Environment.production);
      expect(EnvironmentConfig.enableDebugFeatures, isFalse);
    });

    test('performance monitoring enabled in staging and production', () {
      EnvironmentConfig.setEnvironment(Environment.dev);
      expect(EnvironmentConfig.enablePerformanceMonitoring, isFalse);

      EnvironmentConfig.setEnvironment(Environment.staging);
      expect(EnvironmentConfig.enablePerformanceMonitoring, isTrue);

      EnvironmentConfig.setEnvironment(Environment.production);
      expect(EnvironmentConfig.enablePerformanceMonitoring, isTrue);
    });
  });
}
