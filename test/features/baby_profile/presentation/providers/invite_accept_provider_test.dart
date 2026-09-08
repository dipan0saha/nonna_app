import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import 'package:nonna_app/core/constants/onboarding_storage_keys.dart';
import 'package:nonna_app/core/di/providers.dart';
import 'package:nonna_app/core/enums/user_role.dart';
import 'package:nonna_app/core/services/database_service.dart';
import 'package:nonna_app/core/services/local_storage_service.dart';
import 'package:nonna_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:nonna_app/features/baby_profile/presentation/providers/invite_accept_provider.dart';
import 'package:nonna_app/features/onboarding/presentation/providers/onboarding_coordinator_provider.dart';
import 'package:nonna_app/features/onboarding/presentation/providers/onboarding_types.dart';
import 'package:nonna_app/features/onboarding/presentation/utils/onboarding_invite_helpers.dart';

class _FakeDatabaseService implements DatabaseService {
  _FakeDatabaseService(this._rpcHandler);

  final Future<dynamic> Function(String name, Map<String, dynamic>? params)
      _rpcHandler;

  @override
  Future<dynamic> rpc(String functionName, {Map<String, dynamic>? params}) {
    return _rpcHandler(functionName, params);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('InviteAcceptNotifier', () {
    late ProviderContainer container;
    late _FakeDatabaseService fakeDatabase;
    late LocalStorageService storage;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      storage = LocalStorageService();
      await storage.initialize();
      fakeDatabase = _FakeDatabaseService((name, params) async => null);

      container = ProviderContainer(
        overrides: [
          databaseServiceProvider.overrideWithValue(fakeDatabase),
          localStorageServiceProvider.overrideWithValue(storage),
          isAuthenticatedProvider.overrideWithValue(false),
          currentAuthUserProvider.overrideWithValue(null),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('lookupToken maps preview RPC to found state with owner role',
        () async {
      fakeDatabase = _FakeDatabaseService((name, params) async {
        if (name == 'get_invitation_preview') {
          return {
            'baby_profile_id': 'baby-1',
            'baby_name': 'Luna',
            'inviter_display_name': 'Maya',
            'invitee_email': 'guest@test.com',
            'invited_role': 'owner',
            'status': 'pending',
          };
        }
        return null;
      });
      container.dispose();
      container = ProviderContainer(
        overrides: [
          databaseServiceProvider.overrideWithValue(fakeDatabase),
          localStorageServiceProvider.overrideWithValue(storage),
          isAuthenticatedProvider.overrideWithValue(false),
          currentAuthUserProvider.overrideWithValue(null),
        ],
      );

      await container
          .read(inviteAcceptProvider.notifier)
          .lookupToken('token-1');

      final state = container.read(inviteAcceptProvider);
      expect(state.status, InviteAcceptStatus.found);
      expect(state.babyName, 'Luna');
      expect(state.inviterName, 'Maya');
      expect(state.invitedRole, UserRole.owner);
    });

    test('lookupToken returns expired for preview status expired', () async {
      fakeDatabase = _FakeDatabaseService((name, params) async {
        if (name == 'get_invitation_preview') {
          return {'status': 'expired'};
        }
        return null;
      });
      container.dispose();
      container = ProviderContainer(
        overrides: [
          databaseServiceProvider.overrideWithValue(fakeDatabase),
          localStorageServiceProvider.overrideWithValue(storage),
          isAuthenticatedProvider.overrideWithValue(false),
          currentAuthUserProvider.overrideWithValue(null),
        ],
      );

      await container
          .read(inviteAcceptProvider.notifier)
          .lookupToken('token-2');

      expect(
        container.read(inviteAcceptProvider).status,
        InviteAcceptStatus.expired,
      );
    });

    test('lookupAndSyncCoordinator updates coordinator path from invited_role',
        () async {
      fakeDatabase = _FakeDatabaseService((name, params) async {
        if (name == 'get_invitation_preview') {
          return {
            'baby_profile_id': 'baby-1',
            'baby_name': 'Luna',
            'inviter_display_name': 'Maya',
            'invitee_email': 'guest@test.com',
            'invited_role': 'owner',
            'status': 'pending',
          };
        }
        return null;
      });
      container.dispose();
      container = ProviderContainer(
        overrides: [
          databaseServiceProvider.overrideWithValue(fakeDatabase),
          localStorageServiceProvider.overrideWithValue(storage),
          isAuthenticatedProvider.overrideWithValue(false),
          currentAuthUserProvider.overrideWithValue(null),
        ],
      );

      await container
          .read(inviteAcceptProvider.notifier)
          .lookupAndSyncCoordinator(
            token: 'token-3',
            fallbackPath: OnboardingPath.follower,
          );

      final coordinator = container.read(onboardingCoordinatorProvider);
      expect(coordinator.path, OnboardingPath.coOwner);
      expect(coordinator.pendingInviteToken, 'token-3');
      expect(coordinator.inviteeEmail, 'guest@test.com');
      expect(
        storage.getString(OnboardingStorageKeys.path),
        OnboardingPath.coOwner.name,
      );
    });

    test('accept maps email_mismatch RPC error', () async {
      final user = supabase.User(
        id: 'user-1',
        appMetadata: {},
        userMetadata: {},
        aud: 'authenticated',
        createdAt: DateTime.now().toIso8601String(),
        email: 'wrong@test.com',
      );
      fakeDatabase = _FakeDatabaseService((name, params) async {
        if (name == 'accept_invitation') {
          return {
            'error': 'email_mismatch',
            'invitee_email': 'guest@test.com',
          };
        }
        return null;
      });
      container.dispose();
      container = ProviderContainer(
        overrides: [
          databaseServiceProvider.overrideWithValue(fakeDatabase),
          localStorageServiceProvider.overrideWithValue(storage),
          isAuthenticatedProvider.overrideWithValue(true),
          currentAuthUserProvider.overrideWithValue(user),
        ],
      );

      await container.read(inviteAcceptProvider.notifier).accept('token-4');

      final state = container.read(inviteAcceptProvider);
      expect(state.status, InviteAcceptStatus.error);
      expect(state.error, contains('guest@test.com'));
    });
  });

  group('onboarding invite helpers', () {
    test('resolveInvitePath prefers DB owner role over follower fallback', () {
      const state = InviteAcceptState(
        status: InviteAcceptStatus.found,
        invitedRole: UserRole.owner,
      );

      expect(
        resolveInvitePath(
          inviteState: state,
          fallbackPath: OnboardingPath.follower,
        ),
        OnboardingPath.coOwner,
      );
    });
  });
}
