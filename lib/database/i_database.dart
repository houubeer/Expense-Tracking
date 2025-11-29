/// Abstract database interface for transaction management
/// Enables DIP compliance by decoupling services from concrete database
abstract class IDatabase {
  /// Execute operations within a transaction
  /// Returns the result of the transaction
  Future<T> transaction<T>(Future<T> Function() action);
}
