import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nonna_app/core/widgets/shimmer_placeholder.dart';
import 'package:nonna_app/tiles/storage_usage/providers/storage_usage_provider.dart';
import 'package:nonna_app/tiles/storage_usage/widgets/storage_usage_tile.dart';

StorageUsageInfo _makeInfo({
  int totalBytes = 5 * 1024 * 1024 * 1024,
  int usedBytes = 1 * 1024 * 1024 * 1024,
  int photoCount = 50,
}) {
  final available = totalBytes - usedBytes;
  final pct = (usedBytes / totalBytes) * 100;
  return StorageUsageInfo(
    totalBytes: totalBytes,
    usedBytes: usedBytes,
    availableBytes: available,
    usagePercentage: pct,
    photoCount: photoCount,
    calculatedAt: DateTime.now(),
  );
}

Widget _buildWidget({
  StorageUsageInfo? info,
  bool isLoading = false,
  String? error,
  VoidCallback? onRefresh,
}) {
  return MaterialApp(
    home: Scaffold(
      body: StorageUsageTile(
        info: info,
        isLoading: isLoading,
        error: error,
        onRefresh: onRefresh,
      ),
    ),
  );
}

void main() {
  group('StorageUsageTile', () {
    testWidgets('renders with correct widget key', (tester) async {
      await tester.pumpWidget(_buildWidget());
      expect(find.byKey(const Key('storage_usage_tile')), findsOneWidget);
    });

    testWidgets('shows shimmer when isLoading is true', (tester) async {
      await tester.pumpWidget(_buildWidget(isLoading: true));
      expect(find.byType(ShimmerListTile), findsWidgets);
    });

    testWidgets('shows error view when error is set', (tester) async {
      await tester.pumpWidget(_buildWidget(error: 'Load failed'));
      expect(find.text('Load failed'), findsOneWidget);
    });

    testWidgets('shows unavailable message when info is null', (tester) async {
      await tester.pumpWidget(_buildWidget());
      expect(find.text('Storage data unavailable'), findsOneWidget);
    });

    testWidgets('shows correct header text', (tester) async {
      await tester.pumpWidget(_buildWidget());
      expect(find.text('Storage Usage'), findsOneWidget);
    });

    testWidgets('shows used/total text when info is provided', (tester) async {
      final info = _makeInfo();
      await tester.pumpWidget(_buildWidget(info: info));
      expect(find.byKey(const Key('storage_used_text')), findsOneWidget);
    });

    testWidgets('shows percentage text when info is provided', (tester) async {
      final info = _makeInfo();
      await tester.pumpWidget(_buildWidget(info: info));
      expect(find.byKey(const Key('storage_percentage_text')), findsOneWidget);
    });

    testWidgets('shows progress bar when info is provided', (tester) async {
      final info = _makeInfo();
      await tester.pumpWidget(_buildWidget(info: info));
      expect(find.byKey(const Key('storage_progress_bar')), findsOneWidget);
    });

    testWidgets('shows photo count and available in detail text',
        (tester) async {
      final info = _makeInfo(photoCount: 50);
      await tester.pumpWidget(_buildWidget(info: info));
      expect(find.byKey(const Key('storage_detail_text')), findsOneWidget);
      expect(find.textContaining('50 photos'), findsOneWidget);
    });

    testWidgets('shows singular photo when count is 1', (tester) async {
      final info = _makeInfo(photoCount: 1);
      await tester.pumpWidget(_buildWidget(info: info));
      expect(find.textContaining('1 photo ·'), findsOneWidget);
    });

    testWidgets('error retry calls onRefresh', (tester) async {
      var called = false;
      await tester.pumpWidget(
        _buildWidget(error: 'Oops', onRefresh: () => called = true),
      );
      await tester.tap(find.byIcon(Icons.refresh));
      expect(called, isTrue);
    });

    testWidgets('shows percentage value in text', (tester) async {
      // 1GB / 5GB = 20%
      final info = _makeInfo(
        totalBytes: 5 * 1024 * 1024 * 1024,
        usedBytes: 1 * 1024 * 1024 * 1024,
      );
      await tester.pumpWidget(_buildWidget(info: info));
      expect(find.textContaining('20.0%'), findsOneWidget);
    });
  });
}
