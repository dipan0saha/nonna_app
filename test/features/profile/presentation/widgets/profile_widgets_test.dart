import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/features/profile/presentation/widgets/profile_widgets.dart';

void main() {
  group('ProfileAvatar', () {
    testWidgets('shows initials when no avatarUrl', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProfileAvatar(avatarUrl: null, displayName: 'Jane Doe'),
          ),
        ),
      );
      expect(find.text('JD'), findsOneWidget);
    });

    testWidgets("has key 'profile_avatar'", (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProfileAvatar(avatarUrl: null, displayName: 'Alice'),
          ),
        ),
      );
      expect(find.byKey(const Key('profile_avatar')), findsOneWidget);
    });
  });

  group('ProfileStatCard', () {
    testWidgets('shows label and value text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProfileStatCard(label: 'Events Attended', value: '42'),
          ),
        ),
      );
      expect(find.text('Events Attended'), findsOneWidget);
      expect(find.text('42'), findsOneWidget);
    });

    testWidgets('has correct key', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProfileStatCard(label: 'Photos', value: '7'),
          ),
        ),
      );
      expect(find.byKey(const Key('profile_stat_card_Photos')), findsOneWidget);
    });
  });

  group('ProfileSettingsItem', () {
    testWidgets('shows label text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProfileSettingsItem(
              icon: Icons.edit,
              label: 'Edit Profile',
              onTap: () {},
            ),
          ),
        ),
      );
      expect(find.text('Edit Profile'), findsOneWidget);
    });

    testWidgets('has correct key', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProfileSettingsItem(
              icon: Icons.settings,
              label: 'Settings',
              onTap: () {},
            ),
          ),
        ),
      );
      expect(
        find.byKey(const Key('profile_settings_item_Settings')),
        findsOneWidget,
      );
    });

    testWidgets('triggers onTap callback', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProfileSettingsItem(
              icon: Icons.logout,
              label: 'Logout',
              onTap: () => tapped = true,
            ),
          ),
        ),
      );
      await tester.tap(find.text('Logout'));
      await tester.pump();
      expect(tapped, isTrue);
    });
  });
}
