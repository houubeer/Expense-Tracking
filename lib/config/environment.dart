/// Environment configuration for the application
/// Supports dev, staging, and production environments
enum Environment {
  dev,
  staging,
  production,
}

/// Global environment configuration
class EnvironmentConfig {
  static Environment _current = Environment.dev;

  /// Get the current environment
  static Environment get current => _current;

  /// Set the current environment
  static void setEnvironment(Environment env) {
    _current = env;
  }

  /// Check if running in development
  static bool get isDevelopment => _current == Environment.dev;

  /// Check if running in staging
  static bool get isStaging => _current == Environment.staging;

  /// Check if running in production
  static bool get isProduction => _current == Environment.production;

  /// Get environment-specific database path
  static String get databasePath {
    switch (_current) {
      case Environment.dev:
        return 'dev_expense_tracker.db';
      case Environment.staging:
        return 'staging_expense_tracker.db';
      case Environment.production:
        return 'expense_tracker.db';
    }
  }

  /// Get environment-specific log level
  static String get logLevel {
    switch (_current) {
      case Environment.dev:
        return 'debug';
      case Environment.staging:
        return 'info';
      case Environment.production:
        return 'warning';
    }
  }

  /// Get environment-specific log retention days
  static int get logRetentionDays {
    switch (_current) {
      case Environment.dev:
        return 3; // Keep logs for 3 days in dev
      case Environment.staging:
        return 7; // Keep logs for 7 days in staging
      case Environment.production:
        return 30; // Keep logs for 30 days in production
    }
  }

  /// Get environment-specific error reporting enabled flag
  static bool get errorReportingEnabled {
    switch (_current) {
      case Environment.dev:
        return false; // Don't report errors in dev
      case Environment.staging:
        return true; // Report errors in staging
      case Environment.production:
        return true; // Report errors in production
    }
  }

  /// Get environment name as string
  static String get environmentName {
    switch (_current) {
      case Environment.dev:
        return 'Development';
      case Environment.staging:
        return 'Staging';
      case Environment.production:
        return 'Production';
    }
  }

  /// Get database connection timeout in seconds
  static int get databaseTimeoutSeconds {
    switch (_current) {
      case Environment.dev:
        return 30;
      case Environment.staging:
        return 20;
      case Environment.production:
        return 15;
    }
  }

  /// Enable debug mode features
  static bool get enableDebugFeatures {
    return isDevelopment;
  }

  /// Enable performance monitoring
  static bool get enablePerformanceMonitoring {
    return isStaging || isProduction;
  }
}
