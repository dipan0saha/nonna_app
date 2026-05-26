import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:nonna_app/core/di/connectivity_wrapper.dart';

/// Fake [ConnectivityWrapper] for unit tests.
///
/// Wraps a [StreamController] so tests can emit connectivity events by calling
/// [emit]. [checkConnectivity] returns [initial] synchronously.
class FakeConnectivityWrapper implements ConnectivityWrapper {
  FakeConnectivityWrapper({
    List<ConnectivityResult> initial = const [ConnectivityResult.wifi],
  }) : _initial = initial;

  List<ConnectivityResult> _initial;

  final StreamController<List<ConnectivityResult>> _controller =
      StreamController<List<ConnectivityResult>>.broadcast();

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      _controller.stream;

  @override
  Future<List<ConnectivityResult>> checkConnectivity() async => _initial;

  /// Emit a new connectivity result to all listeners.
  void emit(List<ConnectivityResult> results) => _controller.add(results);

  /// Update the value returned by [checkConnectivity].
  void setInitialResults(List<ConnectivityResult> results) {
    _initial = results;
  }

  /// Close the underlying stream controller.
  Future<void> dispose() => _controller.close();
}
