import 'package:flutter/material.dart';

/// Offline indicator widget
///
/// **Functional Requirements**: Section 3.6.8 – Offline-First Implementation
///
/// Displays a status banner at the top of the screen when the device is
/// offline and optionally when a sync is in progress.
///
/// Features:
/// - Offline status banner with configurable colours
/// - Sync status label
/// - Retry button that invokes a callback
/// - Connectivity detection via a [ValueNotifier] or a raw bool
///
/// Usage:
/// ```dart
/// OfflineIndicator(
///   isOffline: !isConnected,
///   onRetry: () => syncManager.sync(),
/// )
/// ```
class OfflineIndicator extends StatelessWidget {
  /// Creates an [OfflineIndicator].
  ///
  /// [isOffline] controls whether the banner is shown.
  /// [isSyncing] shows an extra "Syncing…" label when `true`.
  /// [onRetry] is invoked when the user taps the retry button.
  /// [message] overrides the default offline message.
  /// [syncMessage] overrides the default syncing message.
  const OfflineIndicator({
    super.key,
    required this.isOffline,
    this.isSyncing = false,
    this.onRetry,
    this.message = 'No internet connection',
    this.syncMessage = 'Syncing data…',
    this.backgroundColor,
    this.textColor,
  });

  /// Whether the device is currently offline
  final bool isOffline;

  /// Whether a background sync is in progress
  final bool isSyncing;

  /// Callback invoked when the user taps the retry button
  final VoidCallback? onRetry;

  /// Offline status message
  final String message;

  /// Sync in-progress message
  final String syncMessage;

  /// Background colour of the banner (defaults to `Colors.red.shade700`)
  final Color? backgroundColor;

  /// Text / icon colour for the banner (defaults to `Colors.white`)
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    if (!isOffline) return const SizedBox.shrink();

    final bgColor = backgroundColor ?? Colors.red.shade700;
    final fgColor = textColor ?? Colors.white;

    return Material(
      color: Colors.transparent,
      child: Container(
        width: double.infinity,
        color: bgColor,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: SafeArea(
          bottom: false,
          child: Row(
            children: [
              Icon(Icons.wifi_off, size: 18, color: fgColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isSyncing ? syncMessage : message,
                  style: TextStyle(
                    color: fgColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (isSyncing) ...[
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(fgColor),
                  ),
                ),
              ] else if (onRetry != null) ...[
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: fgColor,
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(48, 32),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: onRetry,
                  child: Text(
                    'Retry',
                    style: TextStyle(
                      color: fgColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// A stream-driven variant of [OfflineIndicator] that rebuilds automatically
/// when the [connectivityStream] or [syncStatusStream] emits new values.
///
/// Usage:
/// ```dart
/// StreamOfflineIndicator(
///   connectivityStream: offlineCacheManager.connectivityStream,
///   onRetry: () => syncManager.sync(),
/// )
/// ```
class StreamOfflineIndicator extends StatefulWidget {
  /// Creates a [StreamOfflineIndicator].
  ///
  /// [connectivityStream] emits `true` when online, `false` when offline.
  /// [syncStatusStream] optionally emits `true` when syncing.
  const StreamOfflineIndicator({
    super.key,
    required this.connectivityStream,
    this.syncStatusStream,
    this.initiallyOnline = true,
    this.onRetry,
    this.message,
    this.syncMessage,
    this.backgroundColor,
    this.textColor,
  });

  /// Stream of connectivity changes (`true` = online)
  final Stream<bool> connectivityStream;

  /// Optional stream of sync-in-progress state (`true` = syncing)
  final Stream<bool>? syncStatusStream;

  /// Whether the device is assumed to be online before the first stream event
  final bool initiallyOnline;

  /// Callback invoked when the user taps the retry button
  final VoidCallback? onRetry;

  /// Offline status message
  final String? message;

  /// Sync in-progress message
  final String? syncMessage;

  /// Background colour of the banner
  final Color? backgroundColor;

  /// Text / icon colour for the banner
  final Color? textColor;

  @override
  State<StreamOfflineIndicator> createState() => _StreamOfflineIndicatorState();
}

class _StreamOfflineIndicatorState extends State<StreamOfflineIndicator> {
  late bool _isOnline;
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _isOnline = widget.initiallyOnline;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: widget.connectivityStream,
      initialData: _isOnline,
      builder: (context, connectivitySnapshot) {
        _isOnline = connectivitySnapshot.data ?? _isOnline;

        if (widget.syncStatusStream == null) {
          return OfflineIndicator(
            isOffline: !_isOnline,
            isSyncing: _isSyncing,
            onRetry: widget.onRetry,
            message: widget.message ?? 'No internet connection',
            syncMessage: widget.syncMessage ?? 'Syncing data…',
            backgroundColor: widget.backgroundColor,
            textColor: widget.textColor,
          );
        }

        return StreamBuilder<bool>(
          stream: widget.syncStatusStream,
          initialData: _isSyncing,
          builder: (context, syncSnapshot) {
            _isSyncing = syncSnapshot.data ?? _isSyncing;

            return OfflineIndicator(
              isOffline: !_isOnline,
              isSyncing: _isSyncing,
              onRetry: widget.onRetry,
              message: widget.message ?? 'No internet connection',
              syncMessage: widget.syncMessage ?? 'Syncing data…',
              backgroundColor: widget.backgroundColor,
              textColor: widget.textColor,
            );
          },
        );
      },
    );
  }
}
