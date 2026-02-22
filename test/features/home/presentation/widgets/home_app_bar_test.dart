import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/features/home/presentation/widgets/home_app_bar.dart';

Widget _buildAppBar({
  String? babyProfileName,
  int notificationCount = 0,
  VoidCallback? onNotificationTap,
  VoidCallback? onSettingsTap,
  VoidCallback? onBabyProfileTap,
}) {
  return MaterialApp(
    home: Scaffold(
      appBar: HomeAppBar(
        babyProfileName: babyProfileName,
        notificationCount: notificationCount,
        onNotificationTap: onNotificationTap,
        onSettingsTap: onSettingsTap,
        onBabyProfileTap: onBabyProfileTap,
      ),
      body: const SizedBox.shrink(),
    ),
  );
}

void main() {
  group('HomeAppBar', () {
    testWidgets('renders with key home_app_bar', (tester) async {
      await tester.pumpWidget(_buildAppBar());
      expect(find.byKey(const Key('home_app_bar')), findsOneWidget);
    });

    testWidgets('shows default title Nonna when no profile name', (tester) async {
      await tester.pumpWidget(_buildAppBar());
      expect(find.text('Nonna'), findsOneWidget);
    });

    testWidgets('shows baby profile name when provided', (tester) async {
      await tester.pumpWidget(_buildAppBar(babyProfileName: 'Emma'));
      expect(find.text('Emma'), findsOneWidget);
    });

    testWidgets('renders notification icon button', (tester) async {
      await tester.pumpWidget(_buildAppBar());
      expect(
        find.byKey(const Key('notification_icon_button')),
        findsOneWidget,
      );
    });

    testWidgets('renders settings icon button', (tester) async {
      await tester.pumpWidget(_buildAppBar());
      expect(
        find.byKey(const Key('settings_icon_button')),
        findsOneWidget,
      );
    });

    testWidgets('shows badge when notification count > 0', (tester) async {
      await tester.pumpWidget(_buildAppBar(notificationCount: 5));
      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('shows 99+ badge when notification count > 99', (tester) async {
      await tester.pumpWidget(_buildAppBar(notificationCount: 150));
      expect(find.text('99+'), findsOneWidget);
    });

    testWidgets('does not show badge when notification count is 0',
        (tester) async {
      await tester.pumpWidget(_buildAppBar(notificationCount: 0));
      // Badge text '0' should not appear
      expect(find.text('0'), findsNothing);
    });

    testWidgets('calls onNotificationTap when notification button tapped',
        (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        _buildAppBar(onNotificationTap: () => tapped = true),
      );
      await tester.tap(find.byKey(const Key('notification_icon_button')));
      expect(tapped, isTrue);
    });

    testWidgets('calls onSettingsTap when settings button tapped',
        (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        _buildAppBar(onSettingsTap: () => tapped = true),
      );
      await tester.tap(find.byKey(const Key('settings_icon_button')));
      expect(tapped, isTrue);
    });
  });
}
