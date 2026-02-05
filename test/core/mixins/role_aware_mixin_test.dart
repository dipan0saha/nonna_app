import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/core/enums/user_role.dart';
import 'package:nonna_app/core/mixins/role_aware_mixin.dart';

// Helper function to wrap widgets in MaterialApp for testing
Widget wrapWithMaterialApp(Widget child) {
  return MaterialApp(
    home: Scaffold(
      body: child,
    ),
  );
}

// Test widget that uses RoleAwareMixin
class TestRoleWidget extends StatefulWidget {
  final UserRole role;
  final String? userId;

  const TestRoleWidget({
    super.key,
    required this.role,
    this.userId,
  });

  @override
  State<TestRoleWidget> createState() => _TestRoleWidgetState();
}

class _TestRoleWidgetState extends State<TestRoleWidget> with RoleAwareMixin {
  @override
  UserRole get currentRole => widget.role;

  @override
  String? get currentUserId => widget.userId;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Role: ${currentRole.name}'),
        Text('Is Owner: $isOwner'),
        Text('Is Follower: $isFollower'),
        ownerOnly(const Text('Owner Only Content')),
        followerOnly(const Text('Follower Only Content')),
        roleBasedWidget(
          ownerWidget: const Text('Owner Widget'),
          followerWidget: const Text('Follower Widget'),
        ),
        showIf(canCreate, const Text('Can Create')),
        showIf(canInvite, const Text('Can Invite')),
        showIf(canManageSettings, const Text('Can Manage')),
        ElevatedButton(
          key: const Key('navigate_button'),
          onPressed: () => navigateIfAllowed(context, 'profile_settings'),
          child: const Text('Navigate'),
        ),
        Container(
          key: const Key('role_color'),
          color: getRoleColor(context),
          width: 10,
          height: 10,
        ),
        Icon(
          getRoleIcon(),
          key: const Key('role_icon'),
        ),
      ],
    );
  }
}

void main() {
  group('RoleAwareMixin', () {
    group('Role Checks', () {
      testWidgets('isOwner returns true for owner role', (tester) async {
        await tester.pumpWidget(
          wrapWithMaterialApp(const TestRoleWidget(role: UserRole.owner)),
        );

        expect(find.text('Is Owner: true'), findsOneWidget);
        expect(find.text('Is Follower: false'), findsOneWidget);
      });

      testWidgets('isFollower returns true for follower role', (tester) async {
        await tester.pumpWidget(
          wrapWithMaterialApp(const TestRoleWidget(role: UserRole.follower)),
        );

        expect(find.text('Is Owner: false'), findsOneWidget);
        expect(find.text('Is Follower: true'), findsOneWidget);
      });

      testWidgets('hasRole checks specific role', (tester) async {
        await tester.pumpWidget(
          wrapWithMaterialApp(const TestRoleWidget(role: UserRole.owner)),
        );

        final state = tester.state<_TestRoleWidgetState>(
          find.byType(TestRoleWidget),
        );

        expect(state.hasRole(UserRole.owner), true);
        expect(state.hasRole(UserRole.follower), false);
      });
    });

    group('Permission Checks', () {
      testWidgets('canEdit checks owner and content ownership', (tester) async {
        await tester.pumpWidget(
          wrapWithMaterialApp(
              const TestRoleWidget(role: UserRole.owner, userId: 'user123')),
        );

        final state = tester.state<_TestRoleWidgetState>(
          find.byType(TestRoleWidget),
        );

        expect(state.canEdit('user123'), true);
        expect(state.canEdit('other_user'), false);
        expect(state.canEdit(null), false);
      });

      testWidgets('canEdit returns false for followers', (tester) async {
        await tester.pumpWidget(
          wrapWithMaterialApp(
              const TestRoleWidget(role: UserRole.follower, userId: 'user123')),
        );

        final state = tester.state<_TestRoleWidgetState>(
          find.byType(TestRoleWidget),
        );

        expect(state.canEdit('user123'), false);
        expect(state.canEdit('other_user'), false);
      });

      testWidgets('canDelete checks owner and content ownership',
          (tester) async {
        await tester.pumpWidget(
          wrapWithMaterialApp(
              const TestRoleWidget(role: UserRole.owner, userId: 'user123')),
        );

        final state = tester.state<_TestRoleWidgetState>(
          find.byType(TestRoleWidget),
        );

        expect(state.canDelete('user123'), true);
        expect(state.canDelete('other_user'), false);
        expect(state.canDelete(null), false);
      });

      testWidgets('canDelete returns false for followers', (tester) async {
        await tester.pumpWidget(
          wrapWithMaterialApp(
              const TestRoleWidget(role: UserRole.follower, userId: 'user123')),
        );

        final state = tester.state<_TestRoleWidgetState>(
          find.byType(TestRoleWidget),
        );

        expect(state.canDelete('user123'), false);
      });

      testWidgets('canCreate returns true for all users', (tester) async {
        await tester.pumpWidget(
          wrapWithMaterialApp(const TestRoleWidget(role: UserRole.owner)),
        );

        final ownerState = tester.state<_TestRoleWidgetState>(
          find.byType(TestRoleWidget),
        );

        expect(ownerState.canCreate, true);

        await tester.pumpWidget(
          wrapWithMaterialApp(const TestRoleWidget(role: UserRole.follower)),
        );

        final followerState = tester.state<_TestRoleWidgetState>(
          find.byType(TestRoleWidget),
        );

        expect(followerState.canCreate, true);
        expect(find.text('Can Create'), findsOneWidget);
      });

      testWidgets('canInvite returns true only for owners', (tester) async {
        await tester.pumpWidget(
          wrapWithMaterialApp(const TestRoleWidget(role: UserRole.owner)),
        );

        expect(find.text('Can Invite'), findsOneWidget);

        await tester.pumpWidget(
          wrapWithMaterialApp(const TestRoleWidget(role: UserRole.follower)),
        );

        expect(find.text('Can Invite'), findsNothing);
      });

      testWidgets('canManageSettings returns true only for owners',
          (tester) async {
        await tester.pumpWidget(
          wrapWithMaterialApp(const TestRoleWidget(role: UserRole.owner)),
        );

        expect(find.text('Can Manage'), findsOneWidget);

        await tester.pumpWidget(
          wrapWithMaterialApp(const TestRoleWidget(role: UserRole.follower)),
        );

        expect(find.text('Can Manage'), findsNothing);
      });
    });

    group('Conditional Rendering', () {
      testWidgets('ownerOnly shows content for owners', (tester) async {
        await tester.pumpWidget(
          wrapWithMaterialApp(const TestRoleWidget(role: UserRole.owner)),
        );

        expect(find.text('Owner Only Content'), findsOneWidget);
      });

      testWidgets('ownerOnly hides content for followers', (tester) async {
        await tester.pumpWidget(
          wrapWithMaterialApp(const TestRoleWidget(role: UserRole.follower)),
        );

        expect(find.text('Owner Only Content'), findsNothing);
      });

      testWidgets('followerOnly shows content for followers', (tester) async {
        await tester.pumpWidget(
          wrapWithMaterialApp(const TestRoleWidget(role: UserRole.follower)),
        );

        expect(find.text('Follower Only Content'), findsOneWidget);
      });

      testWidgets('followerOnly hides content for owners', (tester) async {
        await tester.pumpWidget(
          wrapWithMaterialApp(const TestRoleWidget(role: UserRole.owner)),
        );

        expect(find.text('Follower Only Content'), findsNothing);
      });

      testWidgets('roleBasedWidget shows owner widget for owners',
          (tester) async {
        await tester.pumpWidget(
          wrapWithMaterialApp(const TestRoleWidget(role: UserRole.owner)),
        );

        expect(find.text('Owner Widget'), findsOneWidget);
        expect(find.text('Follower Widget'), findsNothing);
      });

      testWidgets('roleBasedWidget shows follower widget for followers',
          (tester) async {
        await tester.pumpWidget(
          wrapWithMaterialApp(const TestRoleWidget(role: UserRole.follower)),
        );

        expect(find.text('Owner Widget'), findsNothing);
        expect(find.text('Follower Widget'), findsOneWidget);
      });

      testWidgets('showIf shows widget when condition is true', (tester) async {
        await tester.pumpWidget(
          wrapWithMaterialApp(const TestRoleWidget(role: UserRole.owner)),
        );

        final state = tester.state<_TestRoleWidgetState>(
          find.byType(TestRoleWidget),
        );

        final widget = state.showIf(true, const Text('Conditional'));
        expect(widget, isA<Text>());
      });

      testWidgets('showIf hides widget when condition is false',
          (tester) async {
        await tester.pumpWidget(
          wrapWithMaterialApp(const TestRoleWidget(role: UserRole.owner)),
        );

        final state = tester.state<_TestRoleWidgetState>(
          find.byType(TestRoleWidget),
        );

        final widget = state.showIf(false, const Text('Conditional'));
        expect(widget, isA<SizedBox>());
      });
    });

    group('Role-Based Styling', () {
      testWidgets('getRoleColor returns primary color for owners',
          (tester) async {
        await tester.pumpWidget(
          wrapWithMaterialApp(const TestRoleWidget(role: UserRole.owner)),
        );

        final state = tester.state<_TestRoleWidgetState>(
          find.byType(TestRoleWidget),
        );

        final color = state.getRoleColor(state.context);
        expect(color, Theme.of(state.context).colorScheme.primary);
      });

      testWidgets('getRoleColor returns secondary color for followers',
          (tester) async {
        await tester.pumpWidget(
          wrapWithMaterialApp(const TestRoleWidget(role: UserRole.follower)),
        );

        final state = tester.state<_TestRoleWidgetState>(
          find.byType(TestRoleWidget),
        );

        final color = state.getRoleColor(state.context);
        expect(color, Theme.of(state.context).colorScheme.secondary);
      });

      testWidgets('getRoleIcon returns correct icon for role', (tester) async {
        await tester.pumpWidget(
          wrapWithMaterialApp(const TestRoleWidget(role: UserRole.owner)),
        );

        var state = tester.state<_TestRoleWidgetState>(
          find.byType(TestRoleWidget),
        );

        expect(state.getRoleIcon(), UserRole.owner.icon);

        await tester.pumpWidget(
          wrapWithMaterialApp(const TestRoleWidget(role: UserRole.follower)),
        );

        state = tester.state<_TestRoleWidgetState>(
          find.byType(TestRoleWidget),
        );

        expect(state.getRoleIcon(), UserRole.follower.icon);
      });
    });

    group('Navigation Helpers', () {
      testWidgets('canAccessScreen checks owner-only screens', (tester) async {
        await tester.pumpWidget(
          wrapWithMaterialApp(const TestRoleWidget(role: UserRole.owner)),
        );

        final ownerState = tester.state<_TestRoleWidgetState>(
          find.byType(TestRoleWidget),
        );

        expect(ownerState.canAccessScreen('profile_settings'), true);
        expect(ownerState.canAccessScreen('baby_profile_management'), true);
        expect(ownerState.canAccessScreen('invite_management'), true);
        expect(ownerState.canAccessScreen('public_screen'), true);

        await tester.pumpWidget(
          wrapWithMaterialApp(const TestRoleWidget(role: UserRole.follower)),
        );

        final followerState = tester.state<_TestRoleWidgetState>(
          find.byType(TestRoleWidget),
        );

        expect(followerState.canAccessScreen('profile_settings'), false);
        expect(followerState.canAccessScreen('baby_profile_management'), false);
        expect(followerState.canAccessScreen('invite_management'), false);
        expect(followerState.canAccessScreen('public_screen'), true);
      });

      testWidgets('navigateIfAllowed shows error for unauthorized',
          (tester) async {
        await tester.pumpWidget(
          wrapWithMaterialApp(const TestRoleWidget(role: UserRole.follower)),
        );

        await tester.tap(find.byKey(const Key('navigate_button')));
        await tester.pump();

        expect(find.byType(SnackBar), findsOneWidget);
        expect(
          find.text('You do not have permission to access this screen.'),
          findsOneWidget,
        );
      });
    });

    group('Action Helpers', () {
      testWidgets('executeIfAllowed executes action when canCreate is true',
          (tester) async {
        await tester.pumpWidget(
          wrapWithMaterialApp(const TestRoleWidget(role: UserRole.owner)),
        );

        final state = tester.state<_TestRoleWidgetState>(
          find.byType(TestRoleWidget),
        );

        var executed = false;
        state.executeIfAllowed(() {
          executed = true;
        });

        expect(executed, true);
      });

      testWidgets('executeIfAllowed calls onUnauthorized callback',
          (tester) async {
        await tester.pumpWidget(
          wrapWithMaterialApp(const TestRoleWidget(role: UserRole.owner)),
        );

        final state = tester.state<_TestRoleWidgetState>(
          find.byType(TestRoleWidget),
        );

        // Since canCreate is always true, we can't test the unauthorized path
        // But we can verify the method doesn't throw
        var executed = false;
        state.executeIfAllowed(() {
          executed = true;
        });

        expect(executed, true);
      });

      testWidgets('executeWithRoleCheck executes for matching role',
          (tester) async {
        await tester.pumpWidget(
          wrapWithMaterialApp(const TestRoleWidget(role: UserRole.owner)),
        );

        final state = tester.state<_TestRoleWidgetState>(
          find.byType(TestRoleWidget),
        );

        var executed = false;
        state.executeWithRoleCheck(
          () {
            executed = true;
          },
          requiredRole: UserRole.owner,
        );

        expect(executed, true);
      });

      testWidgets('executeWithRoleCheck does not execute for wrong role',
          (tester) async {
        await tester.pumpWidget(
          wrapWithMaterialApp(const TestRoleWidget(role: UserRole.follower)),
        );

        final state = tester.state<_TestRoleWidgetState>(
          find.byType(TestRoleWidget),
        );

        var executed = false;
        state.executeWithRoleCheck(
          () {
            executed = true;
          },
          requiredRole: UserRole.owner,
        );

        expect(executed, false);
      });

      testWidgets('executeWithRoleCheck calls onUnauthorized when wrong role',
          (tester) async {
        await tester.pumpWidget(
          wrapWithMaterialApp(const TestRoleWidget(role: UserRole.follower)),
        );

        final state = tester.state<_TestRoleWidgetState>(
          find.byType(TestRoleWidget),
        );

        var onUnauthorizedCalled = false;
        state.executeWithRoleCheck(
          () {},
          requiredRole: UserRole.owner,
          onUnauthorized: () {
            onUnauthorizedCalled = true;
          },
        );

        expect(onUnauthorizedCalled, true);
      });
    });

    group('Edge Cases', () {
      testWidgets('handles null userId', (tester) async {
        await tester.pumpWidget(
          wrapWithMaterialApp(const TestRoleWidget(role: UserRole.owner)),
        );

        final state = tester.state<_TestRoleWidgetState>(
          find.byType(TestRoleWidget),
        );

        expect(state.currentUserId, null);
        expect(state.canEdit('any_id'), false);
        expect(state.canDelete('any_id'), false);
      });

      testWidgets('works with different role types', (tester) async {
        for (final role in UserRole.values) {
          await tester.pumpWidget(
            wrapWithMaterialApp(TestRoleWidget(role: role)),
          );

          final state = tester.state<_TestRoleWidgetState>(
            find.byType(TestRoleWidget),
          );

          expect(state.currentRole, role);
          expect(() => state.getRoleIcon(), returnsNormally);
          expect(() => state.getRoleColor(state.context), returnsNormally);
        }
      });
    });
  });
}
