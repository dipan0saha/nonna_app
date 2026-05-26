import 'package:connectivity_plus/connectivity_plus.dart';

/// Thin abstraction over [Connectivity] to allow test injection.
///
/// The default implementation delegates to the real [Connectivity] singleton
/// from `connectivity_plus`. In tests, override [connectivityWrapperProvider]
/// with a [FakeConnectivityWrapper] to control the stream.
abstract class ConnectivityWrapper {
  Stream<List<ConnectivityResult>> get onConnectivityChanged;
  Future<List<ConnectivityResult>> checkConnectivity();
}

/// Production implementation that delegates to [Connectivity].
class DefaultConnectivityWrapper implements ConnectivityWrapper {
  final _connectivity = Connectivity();

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      _connectivity.onConnectivityChanged;

  @override
  Future<List<ConnectivityResult>> checkConnectivity() =>
      _connectivity.checkConnectivity();
}
