import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/app_config.dart';
import '../router/app_router.dart';

/// Normalizes legacy invite/auth URLs and routes them through [GoRouter].
class DeepLinkService {
  DeepLinkService._();

  static final AppLinks _appLinks = AppLinks();
  static StreamSubscription<Uri>? _linkSubscription;
  static bool _initialized = false;
  static String? _capturedInitialRoute;
  static Uri? _pendingAuthCallbackUri;
  static bool _initialLinkConsumed = false;

  /// Resolved GoRouter location from a cold-start deep link, if any.
  static String? get initialRoute => _capturedInitialRoute;

  /// Captures the cold-start URI before [runApp]. Safe to call from [main].
  static Future<void> captureColdStartLink() async {
    if (_initialLinkConsumed) return;
    try {
      final initial = await _appLinks.getInitialLink();
      if (initial == null) return;
      _initialLinkConsumed = true;
      if (_isAuthCallback(initial)) {
        _pendingAuthCallbackUri = initial;
        return;
      }
      _capturedInitialRoute = normalizeToRoute(initial);
    } catch (e) {
      debugPrint('⚠️ Deep link cold-start capture failed: $e');
    }
  }

  /// Restores a pending auth callback after Supabase is initialized.
  static Future<void> processPendingAuthCallback() async {
    final uri = _pendingAuthCallbackUri;
    if (uri == null) return;
    _pendingAuthCallbackUri = null;
    try {
      await restoreAuthSessionFromUri(uri);
      debugPrint('✅ Auth session restored from cold-start callback');
    } catch (e) {
      debugPrint('❌ Cold-start auth callback failed: $e');
    }
  }

  /// Wire cold-start and warm-start deep links. Safe to call once after router mount.
  static Future<void> initialize(GoRouter router) async {
    if (_initialized) return;
    _initialized = true;

    if (!_initialLinkConsumed) {
      try {
        final initial = await _appLinks.getInitialLink();
        if (initial != null) {
          _initialLinkConsumed = true;
          await _handleUri(initial, router);
        }
      } catch (e) {
        debugPrint('⚠️ Deep link initial URI failed: $e');
      }
    }

    _capturedInitialRoute = null;

    _linkSubscription = _appLinks.uriLinkStream.listen(
      (uri) => _handleUri(uri, router),
      onError: (Object e) => debugPrint('⚠️ Deep link stream error: $e'),
    );
  }

  static Future<void> dispose() async {
    await _linkSubscription?.cancel();
    _linkSubscription = null;
    _initialized = false;
    _capturedInitialRoute = null;
    _pendingAuthCallbackUri = null;
    _initialLinkConsumed = false;
  }

  /// Maps external URIs to in-app GoRouter locations.
  @visibleForTesting
  static String? normalizeToRoute(Uri uri) {
    final scheme = uri.scheme.toLowerCase();
    final host = uri.host.toLowerCase();
    final path = uri.path;
    final query = uri.query;

    if (_isAuthCallback(uri)) {
      return null;
    }

    if (scheme == AppConfig.deepLinkScheme) {
      // Canonical: nonna://app/invite-accept?token=...
      if (host == AppConfig.deepLinkHost &&
          (path == '/invite-accept' || path == 'invite-accept')) {
        return query.isEmpty
            ? AppRoutes.inviteAccept
            : '${AppRoutes.inviteAccept}?$query';
      }

      // Legacy: nonna://invite-accept?token=...
      if (host == 'invite-accept') {
        return query.isEmpty
            ? AppRoutes.inviteAccept
            : '${AppRoutes.inviteAccept}?$query';
      }
    }

    if (scheme == 'https' || scheme == 'http') {
      if (AppConfig.universalLinkDomains.contains(host)) {
        if (path == '/invite' || path.startsWith('/invite/')) {
          final tokenFromPath = path.startsWith('/invite/')
              ? path.substring('/invite/'.length)
              : uri.queryParameters['token'];
          if (tokenFromPath != null && tokenFromPath.isNotEmpty) {
            final role = uri.queryParameters['role'];
            final roleSuffix =
                role != null && role.isNotEmpty ? '&role=$role' : '';
            return '${AppRoutes.inviteAccept}?token=$tokenFromPath$roleSuffix';
          }
        }
        if (path == '/invite-accept') {
          return query.isEmpty
              ? AppRoutes.inviteAccept
              : '${AppRoutes.inviteAccept}?$query';
        }
      }
    }

    return null;
  }

  static bool _isAuthCallback(Uri uri) {
    if (uri.scheme != AppConfig.deepLinkScheme) return false;
    final host = uri.host.toLowerCase();
    final path = uri.path.toLowerCase();
    return (host == AppConfig.deepLinkHost && path == '/auth/callback') ||
        path == '/auth/callback';
  }

  /// Whether the auth callback URI uses PKCE (`?code=`).
  @visibleForTesting
  static bool isPkceAuthCallback(Uri uri) =>
      uri.queryParameters.containsKey('code');

  /// Extracts a refresh token from implicit/hash email-confirm redirects (#24).
  @visibleForTesting
  static String? refreshTokenFromAuthCallback(Uri uri) {
    if (uri.fragment.isEmpty) return null;
    return Uri.splitQueryString(uri.fragment)['refresh_token'];
  }

  /// Restores a Supabase session from an auth callback deep link (#24).
  @visibleForTesting
  static Future<bool> restoreAuthSessionFromUri(Uri uri) async {
    final client = Supabase.instance.client.auth;

    if (isPkceAuthCallback(uri)) {
      await client.getSessionFromUrl(uri);
      return true;
    }

    final refreshToken = refreshTokenFromAuthCallback(uri);
    if (refreshToken != null && refreshToken.isNotEmpty) {
      await client.setSession(refreshToken);
      return true;
    }

    await client.getSessionFromUrl(uri);
    return true;
  }

  static Future<void> _handleUri(Uri uri, GoRouter router) async {
    if (_isAuthCallback(uri)) {
      try {
        await restoreAuthSessionFromUri(uri);
        debugPrint('✅ Auth session restored from deep link');
      } catch (e) {
        debugPrint('❌ Auth callback deep link failed: $e');
      }
      return;
    }

    final route = normalizeToRoute(uri);
    if (route == null || route.isEmpty) return;

    debugPrint('🔗 Deep link → $route');
    router.go(route);
  }
}
