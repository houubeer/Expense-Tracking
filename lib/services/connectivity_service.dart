import 'package:flutter/foundation.dart';
import 'dart:async';

/// Service to monitor database and file system connectivity state
class ConnectivityService extends ChangeNotifier {
  ConnectionState _state = ConnectionState.connected;
  String? _errorMessage;
  DateTime? _lastSuccessfulOperation;
  Timer? _reconnectionTimer;
  int _reconnectionAttempts = 0;

  /// Database health check callback - to be set externally
  Future<bool> Function()? healthCheckCallback;

  ConnectionState get state => _state;
  String? get errorMessage => _errorMessage;
  DateTime? get lastSuccessfulOperation => _lastSuccessfulOperation;
  bool get isConnected => _state == ConnectionState.connected;
  bool get isDisconnected => _state == ConnectionState.disconnected;
  bool get isReconnecting => _state == ConnectionState.reconnecting;

  /// Update connection state
  void updateState(ConnectionState newState, {String? error}) {
    if (_state != newState) {
      _state = newState;
      _errorMessage = error;
      
      if (newState == ConnectionState.connected) {
        _lastSuccessfulOperation = DateTime.now();
        _errorMessage = null;
      }
      
      notifyListeners();
    }
  }

  /// Mark successful operation
  void markSuccessfulOperation() {
    _lastSuccessfulOperation = DateTime.now();
    if (_state != ConnectionState.connected) {
      updateState(ConnectionState.connected);
    }
  }

  /// Handle connection failure
  void handleConnectionFailure(String error) {
    updateState(ConnectionState.disconnected, error: error);
  }

  /// Attempt reconnection
  Future<void> attemptReconnection() async {
    if (_state != ConnectionState.disconnected) {
      return;
    }

    updateState(ConnectionState.reconnecting);
    _reconnectionAttempts++;

    // Calculate exponential backoff delay: 1s, 2s, 4s, 8s (max)
    final delaySeconds = (1 << (_reconnectionAttempts - 1).clamp(0, 3));
    final delay = Duration(seconds: delaySeconds);

    // Cancel existing timer if any
    _reconnectionTimer?.cancel();

    _reconnectionTimer = Timer(delay, () async {
      if (healthCheckCallback != null) {
        try {
          final isHealthy = await healthCheckCallback!();
          if (isHealthy) {
            updateState(ConnectionState.connected);
            _reconnectionAttempts = 0;
          } else {
            // Try again with increased backoff
            updateState(ConnectionState.disconnected,
                error: 'Reconnection attempt ${_reconnectionAttempts} failed');
            if (_reconnectionAttempts < 10) {
              // Limit to 10 attempts
              await attemptReconnection();
            }
          }
        } catch (e) {
          updateState(ConnectionState.disconnected,
              error: 'Reconnection error: $e');
          if (_reconnectionAttempts < 10) {
            await attemptReconnection();
          }
        }
      } else {
        // No health check callback, just try to reconnect
        updateState(ConnectionState.connected);
        _reconnectionAttempts = 0;
      }
    });
  }

  /// Reset to initial state
  void reset() {
    _reconnectionTimer?.cancel();
    _reconnectionAttempts = 0;
    _state = ConnectionState.connected;
    _errorMessage = null;
    _lastSuccessfulOperation = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _reconnectionTimer?.cancel();
    super.dispose();
  }
}

/// Connection states for the application
enum ConnectionState {
  /// Successfully connected to database
  connected,
  
  /// Disconnected from database (file system issue, corruption, etc.)
  disconnected,
  
  /// Attempting to reconnect
  reconnecting,
}
