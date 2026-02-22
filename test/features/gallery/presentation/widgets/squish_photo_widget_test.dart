import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/features/gallery/presentation/widgets/squish_photo_widget.dart';

Widget _buildWidget({
  int squishCount = 0,
  bool isSquished = false,
  VoidCallback? onSquish,
}) {
  return MaterialApp(
    home: Scaffold(
      body: SquishPhotoWidget(
        squishCount: squishCount,
        isSquished: isSquished,
        onSquish: onSquish,
      ),
    ),
  );
}

void main() {
  group('SquishPhotoWidget', () {
    testWidgets('shows squish count', (tester) async {
      await tester.pumpWidget(_buildWidget(squishCount: 5));
      expect(find.text('5 squishes'), findsOneWidget);
    });

    testWidgets('shows filled heart when isSquished is true', (tester) async {
      await tester.pumpWidget(_buildWidget(isSquished: true));
      expect(find.byIcon(Icons.favorite), findsOneWidget);
      expect(find.byIcon(Icons.favorite_border), findsNothing);
    });

    testWidgets('shows outline heart when isSquished is false', (tester) async {
      await tester.pumpWidget(_buildWidget(isSquished: false));
      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
      expect(find.byIcon(Icons.favorite), findsNothing);
    });

    testWidgets('calls onSquish callback when tapped', (tester) async {
      var called = false;
      await tester.pumpWidget(_buildWidget(onSquish: () => called = true));
      await tester.tap(find.byKey(const Key('squish_button')));
      await tester.pump();
      expect(called, isTrue);
    });

    testWidgets('does not crash when onSquish is null', (tester) async {
      await tester.pumpWidget(_buildWidget());
      await tester.tap(find.byKey(const Key('squish_button')));
      await tester.pump();
      // No exception = pass
    });
  });
}
