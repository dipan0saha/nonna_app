import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:nonna_app/core/config/app_config.dart';
import 'package:nonna_app/core/enums/user_role.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

/// Device-side Supabase admin helpers for OPS emulator sign-off tests.
/// Requires `--dart-define=SUPABASE_URL` and `--dart-define=SUPABASE_SERVICE_ROLE_KEY`.
class OpsSupabaseTestSupport {
  OpsSupabaseTestSupport._();

  static String get _url =>
      const String.fromEnvironment('SUPABASE_URL', defaultValue: '');
  static String get _serviceRole =>
      const String.fromEnvironment('SUPABASE_SERVICE_ROLE_KEY',
          defaultValue: '');

  static bool get isConfigured => _url.isNotEmpty && _serviceRole.isNotEmpty;

  static Map<String, String> get _headers => {
        'apikey': _serviceRole,
        'Authorization': 'Bearer $_serviceRole',
        'Content-Type': 'application/json',
      };

  static Future<String> generateMagicLink(String email) async {
    final response = await _post(
      '/auth/v1/admin/generate_link',
      {
        'type': 'magiclink',
        'email': email,
        'options': {'redirect_to': 'nonna://app/auth/callback'},
      },
    );
    final link = response['action_link'] as String?;
    if (link == null || link.isEmpty) {
      throw StateError('generate_link missing action_link: $response');
    }
    return link;
  }

  static Future<void> ensureConfirmedUser({
    required String email,
    required String password,
  }) async {
    try {
      await _post(
        '/auth/v1/admin/users',
        {
          'email': email,
          'password': password,
          'email_confirm': true,
        },
      );
    } on StateError catch (e) {
      if (!e.message.contains('already been registered')) rethrow;
    }
  }

  static Future<void> ensureUnconfirmedUser({
    required String email,
    required String password,
  }) async {
    try {
      await _post(
        '/auth/v1/admin/users',
        {
          'email': email,
          'password': password,
          'email_confirm': false,
        },
      );
    } on StateError catch (e) {
      if (!e.message.contains('already been registered')) rethrow;
    }
  }

  static Future<String> generateSignupConfirmLink(String email) async {
    final response = await _post(
      '/auth/v1/admin/generate_link',
      {
        'type': 'signup',
        'email': email,
        'options': {'redirect_to': 'nonna://app/auth/callback'},
      },
    );
    final link = response['action_link'] as String?;
    if (link == null || link.isEmpty) {
      throw StateError('generate_link missing action_link: $response');
    }
    return link;
  }

  static Future<String> signupEmailOtp(String email) async {
    final response = await _post(
      '/auth/v1/admin/generate_link',
      {
        'type': 'signup',
        'email': email,
        'options': {'redirect_to': 'nonna://app/auth/callback'},
      },
    );
    final otp = response['email_otp'] as String?;
    if (otp == null || otp.isEmpty) {
      throw StateError('generate_link missing email_otp: $response');
    }
    return otp;
  }

  /// Follows Supabase verify redirects until we reach the app auth callback URI.
  static Future<Uri> resolveAuthCallbackUri(String actionLink) async {
    var uri = Uri.parse(actionLink);
    for (var i = 0; i < 10; i++) {
      final response = await http.get(uri, headers: {'Accept': '*/*'});
      if (response.statusCode >= 300 &&
          response.statusCode < 400 &&
          response.headers['location'] != null) {
        uri = Uri.parse(response.headers['location']!);
        if (uri.scheme == AppConfig.deepLinkScheme) return uri;
        continue;
      }
      break;
    }
    throw StateError('Could not resolve auth callback from $actionLink');
  }

  /// Creates a baby + owner membership using the signed-in user's session (RLS).
  static Future<String> createOwnedBabyAsSignedInUser() async {
    final client = Supabase.instance.client;
    final userId = client.auth.currentUser?.id;
    if (userId == null) {
      throw StateError('No signed-in user for createOwnedBabyAsSignedInUser');
    }

    final baby = await client
        .from('baby_profiles')
        .insert({
          'name': 'OPS Test Baby',
          'gender': 'unknown',
          'expected_birth_date': DateTime.now()
              .add(const Duration(days: 90))
              .toIso8601String()
              .split('T')
              .first,
        })
        .select('id')
        .single();

    final babyId = baby['id'] as String;
    await client.from('baby_memberships').insert({
      'baby_profile_id': babyId,
      'user_id': userId,
      'role': 'owner',
      'relationship_label': 'Parent',
    });
    return babyId;
  }

  static Future<String> userIdForEmail(String email) async {
    final response = await http.get(
      Uri.parse(
        '$_url/auth/v1/admin/users?email=${Uri.encodeComponent(email)}',
      ),
      headers: _headers,
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError('HTTP ${response.statusCode}: ${response.body}');
    }
    final users = jsonDecode(response.body) as Map<String, dynamic>;
    final rows = users['users'] as List<dynamic>? ?? [];
    if (rows.isEmpty) {
      throw StateError('No auth user for $email');
    }
    return (rows.first as Map<String, dynamic>)['id'] as String;
  }

  static Future<String> latestOwnedBabyProfileId(String ownerUserId) async {
    final uri = Uri.parse('$_url/rest/v1/baby_memberships').replace(
      queryParameters: {
        'user_id': 'eq.$ownerUserId',
        'role': 'eq.owner',
        'removed_at': 'is.null',
        'select': 'baby_profile_id,created_at',
        'order': 'created_at.desc',
        'limit': '1',
      },
    );
    final response = await http.get(uri, headers: {
      ..._headers,
      'Accept': 'application/json',
    });
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError('HTTP ${response.statusCode}: ${response.body}');
    }
    final rows = jsonDecode(response.body) as List<dynamic>;
    if (rows.isEmpty) {
      throw StateError('No baby profile for owner $ownerUserId');
    }
    return (rows.first as Map<String, dynamic>)['baby_profile_id'] as String;
  }

  static Future<void> insertFollowerMembership({
    required String babyProfileId,
    required String followerUserId,
  }) async {
    await Supabase.instance.client.from('baby_memberships').insert({
      'baby_profile_id': babyProfileId,
      'user_id': followerUserId,
      'role': 'follower',
      'relationship_label': 'Grandma',
    });
  }

  static Future<void> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    await Supabase.instance.client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  static Future<void> signOut() async {
    await Supabase.instance.client.auth.signOut();
  }

  static Future<void> ensureUserProfile(String displayName) async {
    final client = Supabase.instance.client;
    final userId = client.auth.currentUser?.id;
    if (userId == null) {
      throw StateError('No signed-in user for ensureUserProfile');
    }

    final now = DateTime.now().toIso8601String();
    await client.from('profiles').upsert({
      'user_id': userId,
      'display_name': displayName.trim(),
      'updated_at': now,
      'created_at': now,
    });
  }

  /// Creates a pending invitation using the signed-in owner's session (RLS).
  static Future<String> createInvitationAsSignedInOwner({
    required String babyProfileId,
    required String inviteeEmail,
    String relationshipLabel = 'Grandma',
    UserRole invitedRole = UserRole.follower,
  }) async {
    final client = Supabase.instance.client;
    final userId = client.auth.currentUser?.id;
    if (userId == null) {
      throw StateError('No signed-in user for createInvitationAsSignedInOwner');
    }

    final tokenHash = 'qa-e2e-${const Uuid().v4()}';
    final now = DateTime.now();
    await client.from('invitations').insert({
      'baby_profile_id': babyProfileId,
      'invited_by_user_id': userId,
      'invitee_email': inviteeEmail.trim().toLowerCase(),
      'relationship_label': relationshipLabel,
      'invited_role': invitedRole.toJson(),
      'token_hash': tokenHash,
      'expires_at': now.add(const Duration(days: 7)).toIso8601String(),
      'status': 'pending',
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    });
    return tokenHash;
  }

  static Future<Map<String, dynamic>> _post(
    String path,
    Map<String, dynamic> body,
  ) async {
    final response = await http.post(
      Uri.parse('$_url$path'),
      headers: _headers,
      body: jsonEncode(body),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError('HTTP ${response.statusCode}: ${response.body}');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}
