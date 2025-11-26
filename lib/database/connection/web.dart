import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';

LazyDatabase connect() {
  return LazyDatabase(() async {
    final result = await WasmDatabase.open(
      databaseName: 'expense_tracker',
      sqlite3Uri: Uri.parse('sqlite3.wasm'),
      driftWorkerUri: Uri.parse('drift_worker.js'),
    );

    if (result.missingFeatures.isNotEmpty) {
      // Depending on your app, you might want to show a warning to the user
      print('Using ${result.chosenImplementation} due to missing features: '
          '${result.missingFeatures}');
    }

    return result.resolvedExecutor;
  });
}
