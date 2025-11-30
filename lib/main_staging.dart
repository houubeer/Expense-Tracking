import 'package:expense_tracking_desktop_app/config/environment.dart';
import 'package:expense_tracking_desktop_app/main.dart' as app;

/// Entry point for staging environment
void main() {
  EnvironmentConfig.setEnvironment(Environment.staging);
  app.main();
}
