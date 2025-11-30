import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracking_desktop_app/providers/app_providers.dart';
import 'package:expense_tracking_desktop_app/services/connectivity_service.dart'
    as service;

/// Banner widget that displays database connection status
/// Shows warnings when disconnected and allows retry attempts
class ConnectionStatusBanner extends ConsumerWidget {
  const ConnectionStatusBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivityService = ref.watch(connectivityServiceProvider);

    return ListenableBuilder(
      listenable: connectivityService,
      builder: (context, _) {
        final state = connectivityService.state;

        // Don't show banner when connected
        if (state == service.ConnectionState.connected) {
          return const SizedBox.shrink();
        }

        return Material(
          color: _getBannerColor(state),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(
                  _getBannerIcon(state),
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _getBannerTitle(state),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      if (connectivityService.errorMessage != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          connectivityService.errorMessage!,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      if (connectivityService.lastSuccessfulOperation !=
                          null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Last success: ${_formatTimestamp(connectivityService.lastSuccessfulOperation!)}',
                          style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (state == service.ConnectionState.disconnected) ...[
                  const SizedBox(width: 12),
                  TextButton(
                    onPressed: () async {
                      await connectivityService.attemptReconnection();
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    child: const Text('Retry'),
                  ),
                ],
                if (state == service.ConnectionState.reconnecting) ...[
                  const SizedBox(width: 12),
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getBannerColor(service.ConnectionState state) {
    switch (state) {
      case service.ConnectionState.disconnected:
        return Colors.red.shade700;
      case service.ConnectionState.reconnecting:
        return Colors.orange.shade700;
      case service.ConnectionState.connected:
        return Colors.green.shade700;
    }
  }

  IconData _getBannerIcon(service.ConnectionState state) {
    switch (state) {
      case service.ConnectionState.disconnected:
        return Icons.cloud_off;
      case service.ConnectionState.reconnecting:
        return Icons.cloud_sync;
      case service.ConnectionState.connected:
        return Icons.cloud_done;
    }
  }

  String _getBannerTitle(service.ConnectionState state) {
    switch (state) {
      case service.ConnectionState.disconnected:
        return 'Database Connection Lost';
      case service.ConnectionState.reconnecting:
        return 'Reconnecting to Database...';
      case service.ConnectionState.connected:
        return 'Connected';
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds}s ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
