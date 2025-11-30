import 'package:expense_tracking_desktop_app/config/environment.dart';
import 'package:expense_tracking_desktop_app/main.dart' as app;

/// Entry point for development environment
void main() {
  EnvironmentConfig.setEnvironment(Environment.dev);
  app.main();
}
