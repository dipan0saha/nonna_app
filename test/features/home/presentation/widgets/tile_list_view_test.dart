import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/core/enums/user_role.dart';
import 'package:nonna_app/core/models/tile_config.dart';
import 'package:nonna_app/core/widgets/shimmer_placeholder.dart';
import 'package:nonna_app/features/home/presentation/widgets/tile_list_view.dart';

TileConfig _makeTile(String id, String defId, int order) {
  final now = DateTime(2024, 1, 1);
  return TileConfig(
    id: id,
    screenId: 'home',
    tileDefinitionId: defId,
    role: UserRole.owner,
    displayOrder: order,
    createdAt: now,
    updatedAt: now,
  );
}

Widget _build({
  List<TileConfig> tiles = const [],
  bool isLoading = false,
  String? error,
  Future<void> Function()? onRefresh,
  VoidCallback? onRetry,
}) {
  return MaterialApp(
    home: Scaffold(
      body: TileListView(
        tiles: tiles,
        isLoading: isLoading,
        error: error,
        onRefresh: onRefresh,
        onRetry: onRetry,
      ),
    ),
  );
}

void main() {
  group('TileListView', () {
    testWidgets('shows shimmer cards when loading', (tester) async {
      await tester.pumpWidget(_build(isLoading: true));
      expect(find.byType(ShimmerCard), findsNWidgets(3));
    });

    testWidgets('shows empty state when tiles list is empty', (tester) async {
      await tester.pumpWidget(_build());
      expect(find.text('No tiles to display'), findsOneWidget);
    });

    testWidgets('shows error view when error is set', (tester) async {
      await tester.pumpWidget(_build(error: 'Something went wrong'));
      expect(find.text('Something went wrong'), findsOneWidget);
    });

    testWidgets('shows retry button when error and onRetry provided',
        (tester) async {
      bool retried = false;
      await tester.pumpWidget(
        _build(error: 'Oops', onRetry: () => retried = true),
      );
      await tester.tap(find.text('Retry'));
      expect(retried, isTrue);
    });

    testWidgets('renders tile cards when tiles are provided', (tester) async {
      final tiles = [
        _makeTile('1', 'weather_tile', 1),
        _makeTile('2', 'photo_tile', 2),
      ];
      await tester.pumpWidget(_build(tiles: tiles));
      expect(find.text('weather_tile'), findsOneWidget);
      expect(find.text('photo_tile'), findsOneWidget);
    });

    testWidgets('has tile_list_view key when tiles are present', (tester) async {
      final tiles = [_makeTile('1', 'some_tile', 1)];
      await tester.pumpWidget(_build(tiles: tiles));
      expect(find.byKey(const Key('tile_list_view')), findsOneWidget);
    });

    testWidgets('wraps list in RefreshIndicator when onRefresh provided',
        (tester) async {
      final tiles = [_makeTile('1', 'some_tile', 1)];
      await tester.pumpWidget(
        _build(
          tiles: tiles,
          onRefresh: () async {},
        ),
      );
      expect(
        find.byKey(const Key('tile_list_refresh_indicator')),
        findsOneWidget,
      );
    });

    testWidgets('does not show RefreshIndicator when onRefresh is null',
        (tester) async {
      final tiles = [_makeTile('1', 'some_tile', 1)];
      await tester.pumpWidget(_build(tiles: tiles));
      expect(
        find.byKey(const Key('tile_list_refresh_indicator')),
        findsNothing,
      );
    });

    testWidgets('loading state hides error and empty state', (tester) async {
      await tester.pumpWidget(_build(isLoading: true, error: 'ignored'));
      expect(find.text('ignored'), findsNothing);
    });
  });
}
