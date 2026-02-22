import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:nonna_app/core/services/observability_service.dart';

/// Handles app crash detection and state recovery between sessions.
///
/// **Functional Requirements**: Section 3.30 - Error Boundaries & Recovery
///
/// Workflow:
/// 1. Call [initialize] at startup to detect a previous crash and restore state.
/// 2. Register [handleCrash] with your global error handler.
/// 3. Call [clearCrashState] once the app has started cleanly.
class CrashRecoveryHandler {
  static const _crashKey = 'crash_recovery_crashed';
  static const _crashMessageKey = 'crash_recovery_message';

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  /// Initialises the handler.
  ///
  /// If a previous crash is detected, calls [restoreState] automatically.
  static Future<void> initialize() async {
    if (hasPreviousCrash()) {
      await restoreState();
    }
    await _markClean();
  }

  // ── Crash handling ─────────────────────────────────────────────────────────

  /// Records the crash and reports it to [ObservabilityService].
  static Future<void> handleCrash(
    Object error,
    StackTrace stackTrace,
  ) async {
    debugPrint('💥 CrashRecoveryHandler: $error');

    await ObservabilityService.captureException(error, stackTrace: stackTrace);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_crashKey, true);
      await prefs.setString(_crashMessageKey, error.toString());
    } catch (e) {
      debugPrint('⚠️  CrashRecoveryHandler: could not persist crash state: $e');
    }
  }

  // ── State restoration ──────────────────────────────────────────────────────

  /// Called after a crash is detected on next startup.
  ///
  /// Override or extend to restore specific navigation/UI state.
  static Future<void> restoreState() async {
    debugPrint('🔄 CrashRecoveryHandler: restoring state after crash');
    // App-specific restoration logic can be added here.
  }

  // ── Crash state ────────────────────────────────────────────────────────────

  /// Returns `true` if the previous session ended in a crash.
  ///
  /// Always `false` before [initialize] is called. After initialization,
  /// the value is cached from [SharedPreferences] so this check is synchronous.
  static bool hasPreviousCrash() {
    return _crashed;
  }

  /// Clears the persisted crash flag once the app has started successfully.
  static void clearCrashState() {
    _crashed = false;
    SharedPreferences.getInstance().then((prefs) {
      prefs.remove(_crashKey);
      prefs.remove(_crashMessageKey);
    });
  }

  // ── Internal ───────────────────────────────────────────────────────────────

  // Cached value set by [initialize] to allow synchronous [hasPreviousCrash]
  // checks without additional async calls.
  static bool _crashed = false;

  static Future<void> _markClean() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _crashed = prefs.getBool(_crashKey) ?? false;
      if (_crashed) {
        debugPrint('⚠️  CrashRecoveryHandler: previous crash detected');
      }
    } catch (e) {
      debugPrint('⚠️  CrashRecoveryHandler: could not read crash state: $e');
    }
  }
}

/// Riverpod provider for [CrashRecoveryHandler].
final crashRecoveryHandlerProvider =
    Provider<CrashRecoveryHandler>((_) => CrashRecoveryHandler());
