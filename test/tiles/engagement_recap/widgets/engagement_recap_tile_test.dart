import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nonna_app/core/widgets/shimmer_placeholder.dart';
import 'package:nonna_app/tiles/engagement_recap/providers/engagement_recap_provider.dart';
import 'package:nonna_app/tiles/engagement_recap/widgets/engagement_recap_tile.dart';

EngagementMetrics _makeMetrics({
  int squishes = 10,
  int comments = 5,
  int rsvps = 3,
}) {
  return EngagementMetrics(
    photoSquishes: squishes,
    photoComments: comments,
    eventRSVPs: rsvps,
    totalEngagement: squishes + comments + rsvps,
    calculatedAt: DateTime.now(),
  );
}

Widget _buildWidget({
  EngagementMetrics? metrics,
  bool isLoading = false,
  String? error,
  VoidCallback? onRefresh,
  void Function(int)? onPeriodChanged,
  int selectedDays = 30,
}) {
  return MaterialApp(
    home: Scaffold(
      body: EngagementRecapTile(
        metrics: metrics,
        isLoading: isLoading,
        error: error,
        onRefresh: onRefresh,
        onPeriodChanged: onPeriodChanged,
        selectedDays: selectedDays,
      ),
    ),
  );
}

void main() {
  group('EngagementRecapTile', () {
    testWidgets('renders with correct widget key', (tester) async {
      await tester.pumpWidget(_buildWidget());
      expect(find.byKey(const Key('engagement_recap_tile')), findsOneWidget);
    });

    testWidgets('shows shimmer when isLoading is true', (tester) async {
      await tester.pumpWidget(_buildWidget(isLoading: true));
      expect(find.byType(ShimmerListTile), findsWidgets);
    });

    testWidgets('shows error view when error is set', (tester) async {
      await tester.pumpWidget(_buildWidget(error: 'Load failed'));
      expect(find.text('Load failed'), findsOneWidget);
    });

    testWidgets('shows empty state when metrics is null', (tester) async {
      await tester.pumpWidget(_buildWidget());
      expect(find.text('No engagement data yet'), findsOneWidget);
    });

    testWidgets('shows correct header text', (tester) async {
      await tester.pumpWidget(_buildWidget());
      expect(find.text('Engagement Recap'), findsOneWidget);
    });

    testWidgets('shows squishes metric when metrics provided', (tester) async {
      final metrics = _makeMetrics(squishes: 7);
      await tester.pumpWidget(_buildWidget(metrics: metrics));
      expect(find.byKey(const Key('squishes_metric')), findsOneWidget);
      expect(find.text('7'), findsOneWidget);
    });

    testWidgets('shows comments metric when metrics provided', (tester) async {
      final metrics = _makeMetrics(comments: 4);
      await tester.pumpWidget(_buildWidget(metrics: metrics));
      expect(find.byKey(const Key('comments_metric')), findsOneWidget);
      expect(find.text('4'), findsOneWidget);
    });

    testWidgets('shows rsvps metric when metrics provided', (tester) async {
      final metrics = _makeMetrics(rsvps: 2);
      await tester.pumpWidget(_buildWidget(metrics: metrics));
      expect(find.byKey(const Key('rsvps_metric')), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('shows total metric when metrics provided', (tester) async {
      final metrics = _makeMetrics(squishes: 10, comments: 5, rsvps: 3);
      await tester.pumpWidget(_buildWidget(metrics: metrics));
      expect(find.byKey(const Key('total_metric')), findsOneWidget);
      expect(find.text('18'), findsOneWidget);
    });

    testWidgets('shows period selector when onPeriodChanged is provided',
        (tester) async {
      await tester.pumpWidget(_buildWidget(onPeriodChanged: (_) {}));
      expect(find.byKey(const Key('period_selector')), findsOneWidget);
    });

    testWidgets('hides period selector when onPeriodChanged is null',
        (tester) async {
      await tester.pumpWidget(_buildWidget());
      expect(find.byKey(const Key('period_selector')), findsNothing);
    });

    testWidgets('period selector shows all period options', (tester) async {
      await tester.pumpWidget(_buildWidget(onPeriodChanged: (_) {}));
      expect(find.text('7d'), findsOneWidget);
      expect(find.text('30d'), findsOneWidget);
      expect(find.text('90d'), findsOneWidget);
    });

    testWidgets('period selector calls onPeriodChanged when segment tapped',
        (tester) async {
      int? selected;
      await tester.pumpWidget(
        _buildWidget(onPeriodChanged: (d) => selected = d, selectedDays: 30),
      );
      await tester.tap(find.text('7d'));
      expect(selected, 7);
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
