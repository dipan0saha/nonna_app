import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nonna_app/core/models/baby_profile.dart';
import 'package:nonna_app/core/widgets/shimmer_placeholder.dart';
import 'package:nonna_app/tiles/due_date_countdown/providers/due_date_countdown_provider.dart';
import 'package:nonna_app/tiles/due_date_countdown/widgets/due_date_countdown_tile.dart';

BabyCountdown _makeCountdown({
  String id = 'bp1',
  String name = 'Baby Doe',
  int daysUntil = 30,
  bool isPastDue = false,
}) {
  final now = DateTime.now();
  final profile = BabyProfile(
    id: id,
    name: name,
    createdAt: now,
    updatedAt: now,
    expectedBirthDate: now.add(Duration(days: daysUntil)),
  );
  return BabyCountdown(
    profile: profile,
    daysUntilDueDate: daysUntil,
    isPastDue: isPastDue,
    formattedCountdown: isPastDue ? '${daysUntil.abs()} days overdue' : '$daysUntil days until due date',
  );
}

Widget _buildWidget({
  List<BabyCountdown> countdowns = const [],
  bool isLoading = false,
  String? error,
  VoidCallback? onRefresh,
}) {
  return MaterialApp(
    home: Scaffold(
      body: DueDateCountdownTile(
        countdowns: countdowns,
        isLoading: isLoading,
        error: error,
        onRefresh: onRefresh,
      ),
    ),
  );
}

void main() {
  group('DueDateCountdownTile', () {
    testWidgets('renders with correct widget key', (tester) async {
      await tester.pumpWidget(_buildWidget());
      expect(find.byKey(const Key('due_date_countdown_tile')), findsOneWidget);
    });

    testWidgets('shows shimmer when isLoading is true', (tester) async {
      await tester.pumpWidget(_buildWidget(isLoading: true));
      expect(find.byType(ShimmerListTile), findsWidgets);
    });

    testWidgets('shows error view when error is set', (tester) async {
      await tester.pumpWidget(_buildWidget(error: 'Load error'));
      expect(find.text('Load error'), findsOneWidget);
    });

    testWidgets('shows empty state when countdowns list is empty', (tester) async {
      await tester.pumpWidget(_buildWidget());
      expect(find.text('No due dates to display'), findsOneWidget);
    });

    testWidgets('shows correct header text', (tester) async {
      await tester.pumpWidget(_buildWidget());
      expect(find.text('Due Date Countdown'), findsOneWidget);
    });

    testWidgets('shows countdown rows when provided', (tester) async {
      final countdowns = [
        _makeCountdown(id: 'bp1', name: 'Baby A'),
        _makeCountdown(id: 'bp2', name: 'Baby B'),
      ];
      await tester.pumpWidget(_buildWidget(countdowns: countdowns));
      expect(find.byKey(const Key('countdown_row_bp1')), findsOneWidget);
      expect(find.byKey(const Key('countdown_row_bp2')), findsOneWidget);
    });

    testWidgets('shows baby name for each countdown', (tester) async {
      final countdown = _makeCountdown(id: 'bp1', name: 'Emma');
      await tester.pumpWidget(_buildWidget(countdowns: [countdown]));
      expect(find.text('Emma'), findsOneWidget);
    });

    testWidgets('shows days badge for each countdown', (tester) async {
      final countdown = _makeCountdown(id: 'bp1', daysUntil: 42);
      await tester.pumpWidget(_buildWidget(countdowns: [countdown]));
      expect(find.byKey(const Key('days_badge_bp1')), findsOneWidget);
      expect(find.text('42d'), findsOneWidget);
    });

    testWidgets('shows Born! badge when past due', (tester) async {
      final countdown = _makeCountdown(id: 'bp1', daysUntil: -3, isPastDue: true);
      await tester.pumpWidget(_buildWidget(countdowns: [countdown]));
      expect(find.text('Born!'), findsOneWidget);
    });

    testWidgets('shows formatted countdown text', (tester) async {
      final countdown = _makeCountdown(id: 'bp1', daysUntil: 10);
      await tester.pumpWidget(_buildWidget(countdowns: [countdown]));
      expect(find.text('10 days until due date'), findsOneWidget);
    });

    testWidgets('error retry calls onRefresh', (tester) async {
      var called = false;
      await tester.pumpWidget(
        _buildWidget(error: 'Oops', onRefresh: () => called = true),
      );
      await tester.tap(find.byIcon(Icons.refresh));
      expect(called, isTrue);
    });
  });
}
