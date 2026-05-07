import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

String fdRunId() {
  final now = DateTime.now();
  final date =
      '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
  final time =
      '${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}';
  return 'e2e_${date}_$time';
}

Future<void> fdGoToTab(WidgetTester tester, String label) async {
  final navBar = find.byKey(const Key('app_bottom_nav_bar'));
  if (navBar.evaluate().isNotEmpty) {
    final labelFinder =
        find.descendant(of: navBar, matching: find.text(label)).first;
    await tester.tap(labelFinder);
    await tester.pumpAndSettle();
    return;
  }

  final navRail = find.byKey(const Key('app_navigation_rail'));
  if (navRail.evaluate().isNotEmpty) {
    final labelFinder =
        find.descendant(of: navRail, matching: find.text(label));
    if (labelFinder.evaluate().isNotEmpty) {
      await tester.tap(labelFinder.first);
      await tester.pumpAndSettle();
      return;
    }
  }

  throw TestFailure('Could not find navigation controls for tab: $label');
}

Future<void> fdOpenProfileFromHome(WidgetTester tester) async {
  final avatarButton = find.byKey(const Key('profile_avatar_button'));
  expect(
    avatarButton,
    findsOneWidget,
    reason: 'Expected profile avatar in Home app bar',
  );
  await tester.tap(avatarButton);
  await tester.pumpAndSettle();
}

bool fdExists(Finder finder) => finder.evaluate().isNotEmpty;

Finder fdByKeyPrefix(String prefix) {
  return find.byWidgetPredicate((widget) {
    final key = widget.key;
    if (key is ValueKey<String>) {
      return key.value.startsWith(prefix);
    }
    return false;
  });
}

Future<void> fdTapIfExists(WidgetTester tester, Finder finder) async {
  if (!fdExists(finder)) return;
  await tester.tap(finder.first);
  await tester.pumpAndSettle();
}
