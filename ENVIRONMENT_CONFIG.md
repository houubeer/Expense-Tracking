# Environment Configuration

This application supports three environments: **Development**, **Staging**, and **Production**.

## Running Different Environments

### Development

```bash
flutter run -t lib/main_dev.dart
```

### Staging

```bash
flutter run -t lib/main_staging.dart
```

### Production

```bash
flutter run -t lib/main_production.dart
```

## Building for Different Environments

### Development Build

```bash
flutter build windows -t lib/main_dev.dart
```

### Staging Build

```bash
flutter build windows -t lib/main_staging.dart
```

### Production Build

```bash
flutter build windows -t lib/main_production.dart
```

## Environment-Specific Configuration

Each environment has different configurations:

### Development

- **Database**: `dev_expense_tracker.db`
- **Log Level**: Debug (verbose logging)
- **Log Retention**: 3 days
- **Error Reporting**: Disabled
- **Debug Features**: Enabled

### Staging

- **Database**: `staging_expense_tracker.db`
- **Log Level**: Info
- **Log Retention**: 7 days
- **Error Reporting**: Enabled
- **Debug Features**: Disabled

### Production

- **Database**: `expense_tracker.db`
- **Log Level**: Warning (minimal logging)
- **Log Retention**: 30 days
- **Error Reporting**: Enabled
- **Debug Features**: Disabled

## Configuration File

All environment settings are centralized in `lib/config/environment.dart`. To add new environment-specific configuration:

1. Add a new getter in the `EnvironmentConfig` class
2. Implement environment-specific values using a switch statement
3. Access the configuration anywhere using `EnvironmentConfig.propertyName`

## Example Usage

```dart
import 'package:expense_tracking_desktop_app/config/environment.dart';

// Check current environment
if (EnvironmentConfig.isDevelopment) {
  print('Running in development mode');
}

// Get environment-specific values
final dbPath = EnvironmentConfig.databasePath;
final logLevel = EnvironmentConfig.logLevel;
```

## Default Environment

When running `flutter run` or `lib/main.dart` directly, the application defaults to **Development** environment.
