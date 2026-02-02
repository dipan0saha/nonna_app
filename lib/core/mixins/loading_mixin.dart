import 'package:flutter/material.dart';

/// Loading state mixin
///
/// Provides loading state management and loading indicators
/// for async operations.
mixin LoadingMixin<T extends StatefulWidget> on State<T> {
  // Loading state
  bool _isLoading = false;

  // Loading state for specific operations
  final Map<String, bool> _loadingStates = {};

  // ============================================================
  // Loading State Management
  // ============================================================

  /// Get loading state
  bool get isLoading => _isLoading;

  /// Set loading state
  set isLoading(bool value) {
    if (_isLoading != value && mounted) {
      setState(() {
        _isLoading = value;
      });
    }
  }

  /// Check if specific operation is loading
  bool isLoadingFor(String operation) {
    return _loadingStates[operation] ?? false;
  }

  /// Set loading state for specific operation
  void setLoadingFor(String operation, bool value) {
    if (mounted) {
      setState(() {
        _loadingStates[operation] = value;
      });
    }
  }

  /// Clear loading state for operation
  void clearLoadingFor(String operation) {
    if (mounted) {
      setState(() {
        _loadingStates.remove(operation);
      });
    }
  }

  /// Clear all loading states
  void clearAllLoading() {
    if (mounted) {
      setState(() {
        _isLoading = false;
        _loadingStates.clear();
      });
    }
  }

  // ============================================================
  // Async Operation Helpers
  // ============================================================

  /// Execute async operation with loading state
  Future<R?> withLoading<R>(Future<R> Function() operation) async {
    if (isLoading) return null;

    isLoading = true;
    try {
      return await operation();
    } finally {
      isLoading = false;
    }
  }

  /// Execute async operation with specific loading key
  Future<R?> withLoadingFor<R>(
    String key,
    Future<R> Function() operation,
  ) async {
    if (isLoadingFor(key)) return null;

    setLoadingFor(key, true);
    try {
      return await operation();
    } finally {
      setLoadingFor(key, false);
    }
  }

  /// Execute async operation with error handling
  Future<R?> withLoadingAndError<R>(
    Future<R> Function() operation, {
    void Function(Object error)? onError,
  }) async {
    if (isLoading) return null;

    isLoading = true;
    try {
      return await operation();
    } catch (e) {
      if (onError != null) {
        onError(e);
      } else {
        // Show default error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('An error occurred: ${e.toString()}')),
          );
        }
      }
      return null;
    } finally {
      isLoading = false;
    }
  }

  // ============================================================
  // Widget Helpers
  // ============================================================

  /// Build widget with loading overlay
  Widget buildWithLoading({
    required Widget child,
    Widget? loadingWidget,
  }) {
    return Stack(
      children: [
        child,
        if (isLoading)
          loadingWidget ??
              Container(
                color: Colors.black.withOpacity(0.3),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
      ],
    );
  }

  /// Build widget that shows loading indicator when loading
  Widget buildLoadingAware({
    required Widget child,
    Widget? loadingWidget,
  }) {
    if (isLoading) {
      return loadingWidget ??
          const Center(
            child: CircularProgressIndicator(),
          );
    }
    return child;
  }

  /// Build button with loading state
  Widget buildLoadingButton({
    required VoidCallback? onPressed,
    required Widget child,
    bool? enabled,
  }) {
    final isEnabled = (enabled ?? true) && !isLoading;
    
    return ElevatedButton(
      onPressed: isEnabled ? onPressed : null,
      child: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : child,
    );
  }

  /// Build button for specific operation
  Widget buildOperationButton({
    required String operation,
    required VoidCallback? onPressed,
    required Widget child,
    bool? enabled,
  }) {
    final isOperationLoading = isLoadingFor(operation);
    final isEnabled = (enabled ?? true) && !isOperationLoading;
    
    return ElevatedButton(
      onPressed: isEnabled ? onPressed : null,
      child: isOperationLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : child,
    );
  }

  // ============================================================
  // Conditional Actions
  // ============================================================

  /// Execute action only if not loading
  void executeIfNotLoading(VoidCallback action) {
    if (!isLoading) {
      action();
    }
  }

  /// Execute action for specific operation only if not loading
  void executeOperationIfNotLoading(String operation, VoidCallback action) {
    if (!isLoadingFor(operation)) {
      action();
    }
  }

  // ============================================================
  // Loading Indicators
  // ============================================================

  /// Show loading dialog
  void showLoadingDialog({String? message}) {
    if (!mounted) return;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 20),
              Expanded(
                child: Text(message ?? 'Loading...'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Hide loading dialog
  void hideLoadingDialog() {
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  // ============================================================
  // Cleanup
  // ============================================================

  @override
  void dispose() {
    _loadingStates.clear();
    super.dispose();
  }
}
