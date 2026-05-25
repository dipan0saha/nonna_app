import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nonna_app/core/enums/gender.dart';
import 'package:nonna_app/core/models/baby_profile.dart';
import 'package:nonna_app/core/widgets/shimmer_placeholder.dart';
import 'package:nonna_app/flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nonna_app/tiles/new_baby_welcome/widgets/new_baby_welcome_tile.dart';

// ---------------------------------------------------------------------------
// Factory helpers
// ---------------------------------------------------------------------------

BabyProfile _makeProfile({
  int daysAgo = 0,
  Gender gender = Gender.male,
  double? weightKg = 3.45,
  double? heightCm = 51.0,
}) {
  final now = DateTime.now();
  final birthDate =
      DateTime(now.year, now.month, now.day).subtract(Duration(days: daysAgo));
  return BabyProfile(
    id: 'bp_1',
    name: 'Little Alex',
    gender: gender,
    actualBirthDate: birthDate,
    birthWeightKg: weightKg,
    birthHeightCm: heightCm,
    createdAt: now,
    updatedAt: now,
  );
}

Widget _buildWidget({
  BabyProfile? babyProfile,
  bool isLoading = false,
  String? error,
  VoidCallback? onRefresh,
}) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: NewBabyWelcomeTile(
        babyProfile: babyProfile,
        isLoading: isLoading,
        error: error,
        onRefresh: onRefresh,
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('NewBabyWelcomeTile', () {
    testWidgets('renders with correct widget key', (tester) async {
      await tester.pumpWidget(_buildWidget());
      await tester.pump();
      expect(find.byKey(const Key('new_baby_welcome_tile')), findsOneWidget);
    });

    testWidgets('shows ShimmerPlaceholder widgets when isLoading is true',
        (tester) async {
      await tester.pumpWidget(_buildWidget(isLoading: true));
      await tester.pump();
      expect(find.byType(ShimmerPlaceholder), findsWidgets);
    });

    testWidgets('shows error text when error is provided', (tester) async {
      await tester.pumpWidget(_buildWidget(error: 'Something went wrong'));
      await tester.pump();
      expect(find.text('Something went wrong'), findsOneWidget);
    });

    testWidgets('shows Retry TextButton when error + onRefresh provided',
        (tester) async {
      bool called = false;
      await tester.pumpWidget(
        _buildWidget(error: 'Failed', onRefresh: () => called = true),
      );
      await tester.pump();
      final retryBtn = find.byType(TextButton);
      expect(retryBtn, findsOneWidget);
      await tester.tap(retryBtn);
      expect(called, isTrue);
    });

    testWidgets('renders SizedBox.shrink when babyProfile is null',
        (tester) async {
      await tester.pumpWidget(_buildWidget());
      await tester.pump();
      expect(find.text('Little Alex'), findsNothing);
    });

    testWidgets('displays baby name when profile provided', (tester) async {
      await tester.pumpWidget(_buildWidget(babyProfile: _makeProfile()));
      await tester.pump();
      expect(find.text('Little Alex'), findsOneWidget);
    });

    testWidgets('displays weight and height when provided', (tester) async {
      await tester.pumpWidget(
        _buildWidget(
          babyProfile: _makeProfile(weightKg: 3.450, heightCm: 51.0),
        ),
      );
      await tester.pump();
      expect(find.text('3.450 kg'), findsOneWidget);
      expect(find.text('51.0 cm'), findsOneWidget);
    });

    testWidgets('shows born-today badge when daysSince is 0', (tester) async {
      await tester
          .pumpWidget(_buildWidget(babyProfile: _makeProfile(daysAgo: 0)));
      await tester.pump();
      expect(find.text('🎉 Born today!'), findsOneWidget);
    });

    testWidgets('shows singular day label when daysSince is 1', (tester) async {
      await tester
          .pumpWidget(_buildWidget(babyProfile: _makeProfile(daysAgo: 1)));
      await tester.pump();
      expect(find.text('🎉 1 day old'), findsOneWidget);
    });

    testWidgets('shows plural day label when daysSince is 5', (tester) async {
      await tester
          .pumpWidget(_buildWidget(babyProfile: _makeProfile(daysAgo: 5)));
      await tester.pump();
      expect(find.text('🎉 5 days old'), findsOneWidget);
    });

    testWidgets('does not show Retry button when onRefresh is null',
        (tester) async {
      await tester.pumpWidget(_buildWidget(error: 'Oops'));
      await tester.pump();
      expect(find.byType(TextButton), findsNothing);
    });
  });
}
