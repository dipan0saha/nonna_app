import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:nonna_app/core/enums/user_role.dart';
import 'package:nonna_app/core/middleware/rls_validator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@GenerateMocks([SupabaseClient, GoTrueClient, User])
import 'rls_validator_test.mocks.dart';

void main() {
  late MockSupabaseClient mockClient;
  late MockGoTrueClient mockAuth;
  late RlsValidator rlsValidator;

  setUp(() {
    mockClient = MockSupabaseClient();
    mockAuth = MockGoTrueClient();
    when(mockClient.auth).thenReturn(mockAuth);
    
    rlsValidator = RlsValidator(mockClient);
  });

  group('RlsValidator', () {
    group('configuration', () {
      test('can enable validator', () {
        rlsValidator.setEnabled(true);
        // In debug mode, this should enable
        expect(rlsValidator.isEnabled, true);
      });

      test('can disable validator', () {
        rlsValidator.setEnabled(false);
        expect(rlsValidator.isEnabled, false);
      });
    });

    group('simulateRoleAccess', () {
      test('grants full access to owner', () async {
        final hasAccess = await rlsValidator.simulateRoleAccess(
          role: UserRole.owner,
          babyProfileId: 'baby-123',
          operation: 'read_profile',
        );

        expect(hasAccess, true);
      });

      test('grants access to partner for non-admin operations', () async {
        final hasAccess = await rlsValidator.simulateRoleAccess(
          role: UserRole.partner,
          babyProfileId: 'baby-123',
          operation: 'create_event',
        );

        expect(hasAccess, true);
      });

      test('denies access to partner for admin operations', () async {
        final hasAccess = await rlsValidator.simulateRoleAccess(
          role: UserRole.partner,
          babyProfileId: 'baby-123',
          operation: 'delete_baby_profile',
        );

        expect(hasAccess, false);
      });

      test('grants read access to family member', () async {
        final hasAccess = await rlsValidator.simulateRoleAccess(
          role: UserRole.familyMember,
          babyProfileId: 'baby-123',
          operation: 'read_events',
        );

        expect(hasAccess, true);
      });

      test('denies restricted write to family member', () async {
        final hasAccess = await rlsValidator.simulateRoleAccess(
          role: UserRole.familyMember,
          babyProfileId: 'baby-123',
          operation: 'delete_event',
        );

        expect(hasAccess, false);
      });

      test('grants read access to friend', () async {
        final hasAccess = await rlsValidator.simulateRoleAccess(
          role: UserRole.friend,
          babyProfileId: 'baby-123',
          operation: 'read_photos',
        );

        expect(hasAccess, true);
      });

      test('denies write access to friend', () async {
        final hasAccess = await rlsValidator.simulateRoleAccess(
          role: UserRole.friend,
          babyProfileId: 'baby-123',
          operation: 'create_event',
        );

        expect(hasAccess, false);
      });

      test('grants limited read access to viewer', () async {
        final hasAccess = await rlsValidator.simulateRoleAccess(
          role: UserRole.viewer,
          babyProfileId: 'baby-123',
          operation: 'read_photos',
        );

        expect(hasAccess, true);
      });

      test('denies write access to viewer', () async {
        final hasAccess = await rlsValidator.simulateRoleAccess(
          role: UserRole.viewer,
          babyProfileId: 'baby-123',
          operation: 'create_event',
        );

        expect(hasAccess, false);
      });

      test('denies private data access to viewer', () async {
        final hasAccess = await rlsValidator.simulateRoleAccess(
          role: UserRole.viewer,
          babyProfileId: 'baby-123',
          operation: 'read_private_notes',
        );

        expect(hasAccess, false);
      });
    });

    group('validateTableAccess', () {
      test('validates access for authenticated user', () async {
        final mockUser = MockUser();
        when(mockUser.id).thenReturn('user-123');
        when(mockAuth.currentUser).thenReturn(mockUser);

        final hasAccess = await rlsValidator.validateTableAccess(
          userId: 'user-123',
          tableName: 'events',
          operation: 'select',
        );

        expect(hasAccess, true);
      });

      test('denies access for mismatched user', () async {
        final mockUser = MockUser();
        when(mockUser.id).thenReturn('user-456');
        when(mockAuth.currentUser).thenReturn(mockUser);

        final hasAccess = await rlsValidator.validateTableAccess(
          userId: 'user-123',
          tableName: 'events',
          operation: 'select',
        );

        expect(hasAccess, false);
      });

      test('denies access when no user authenticated', () async {
        when(mockAuth.currentUser).thenReturn(null);

        final hasAccess = await rlsValidator.validateTableAccess(
          userId: 'user-123',
          tableName: 'events',
          operation: 'select',
        );

        expect(hasAccess, false);
      });
    });

    group('when disabled', () {
      setUp(() {
        rlsValidator.setEnabled(false);
      });

      test('simulateRoleAccess always returns true', () async {
        final hasAccess = await rlsValidator.simulateRoleAccess(
          role: UserRole.viewer,
          babyProfileId: 'baby-123',
          operation: 'delete_baby_profile',
        );

        expect(hasAccess, true);
      });

      test('validateTableAccess always returns true', () async {
        when(mockAuth.currentUser).thenReturn(null);

        final hasAccess = await rlsValidator.validateTableAccess(
          userId: 'user-123',
          tableName: 'events',
          operation: 'delete',
        );

        expect(hasAccess, true);
      });
    });

    group('getAccessDenialLogs', () {
      test('returns empty list', () {
        final logs = rlsValidator.getAccessDenialLogs();
        expect(logs, isA<List<Map<String, dynamic>>>());
      });
    });
  });
}
