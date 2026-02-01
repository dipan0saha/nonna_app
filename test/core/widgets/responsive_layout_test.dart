import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/core/widgets/responsive_layout.dart';
import 'package:nonna_app/core/utils/screen_size_utils.dart';

void main() {
  group('ResponsiveLayout', () {
    testWidgets('shows mobile widget on mobile screens', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        const MaterialApp(
          home: ResponsiveLayout(
            mobile: Text('Mobile'),
            tablet: Text('Tablet'),
            desktop: Text('Desktop'),
          ),
        ),
      );

      expect(find.text('Mobile'), findsOneWidget);
      expect(find.text('Tablet'), findsNothing);
      expect(find.text('Desktop'), findsNothing);
    });

    testWidgets('shows tablet widget on tablet screens', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        const MaterialApp(
          home: ResponsiveLayout(
            mobile: Text('Mobile'),
            tablet: Text('Tablet'),
            desktop: Text('Desktop'),
          ),
        ),
      );

      expect(find.text('Mobile'), findsNothing);
      expect(find.text('Tablet'), findsOneWidget);
      expect(find.text('Desktop'), findsNothing);
    });

    testWidgets('shows desktop widget on desktop screens', (tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        const MaterialApp(
          home: ResponsiveLayout(
            mobile: Text('Mobile'),
            tablet: Text('Tablet'),
            desktop: Text('Desktop'),
          ),
        ),
      );

      expect(find.text('Mobile'), findsNothing);
      expect(find.text('Tablet'), findsNothing);
      expect(find.text('Desktop'), findsOneWidget);
    });

    testWidgets('falls back to mobile when tablet is null', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        const MaterialApp(
          home: ResponsiveLayout(
            mobile: Text('Mobile'),
          ),
        ),
      );

      expect(find.text('Mobile'), findsOneWidget);
    });
  });

  group('ResponsiveBuilder', () {
    testWidgets('provides device type and screen width', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          home: ResponsiveBuilder(
            builder: (context, deviceType, screenWidth) {
              return Text('$deviceType - $screenWidth');
            },
          ),
        ),
      );

      expect(find.textContaining('mobile'), findsOneWidget);
      expect(find.textContaining('400'), findsOneWidget);
    });
  });

  group('ResponsiveValue', () {
    testWidgets('returns mobile value on mobile', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final value = const ResponsiveValue<int>(
                mobile: 1,
                tablet: 2,
                desktop: 3,
              ).value(context);
              
              return Text('Value: $value');
            },
          ),
        ),
      );

      expect(find.text('Value: 1'), findsOneWidget);
    });
  });

  group('ResponsivePadding', () {
    testWidgets('applies correct padding', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ResponsivePadding(
            mobile: EdgeInsets.all(8),
            desktop: EdgeInsets.all(24),
            child: Text('Content'),
          ),
        ),
      );

      expect(find.text('Content'), findsOneWidget);
      final padding = tester.widget<Padding>(find.byType(Padding));
      expect(padding.padding, isA<EdgeInsets>());
    });
  });

  group('ResponsiveContainer', () {
    testWidgets('creates container with max width', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ResponsiveContainer(
            child: Text('Content'),
          ),
        ),
      );

      expect(find.text('Content'), findsOneWidget);
      expect(find.byType(ConstrainedBox), findsOneWidget);
    });
  });

  group('ResponsiveGrid', () {
    testWidgets('creates grid with responsive columns', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ResponsiveGrid(
              children: List.generate(
                6,
                (index) => Text('Item $index'),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(GridView), findsOneWidget);
      expect(find.text('Item 0'), findsOneWidget);
    });
  });

  group('ResponsiveWrap', () {
    testWidgets('creates wrap with responsive spacing', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ResponsiveWrap(
            children: List.generate(
              3,
              (index) => Text('Item $index'),
            ),
          ),
        ),
      );

      expect(find.byType(Wrap), findsOneWidget);
      expect(find.text('Item 0'), findsOneWidget);
    });
  });

  group('AdaptiveColumns', () {
    testWidgets('stacks vertically on small screens', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        const MaterialApp(
          home: AdaptiveColumns(
            children: [
              Text('Left'),
              Text('Right'),
            ],
          ),
        ),
      );

      expect(find.byType(Column), findsOneWidget);
      expect(find.text('Left'), findsOneWidget);
      expect(find.text('Right'), findsOneWidget);
    });

    testWidgets('displays side-by-side on large screens', (tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        const MaterialApp(
          home: AdaptiveColumns(
            children: [
              Text('Left'),
              Text('Right'),
            ],
          ),
        ),
      );

      expect(find.byType(Row), findsOneWidget);
      expect(find.text('Left'), findsOneWidget);
      expect(find.text('Right'), findsOneWidget);
    });
  });

  group('OrientationLayout', () {
    testWidgets('shows portrait widget in portrait', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        const MaterialApp(
          home: OrientationLayout(
            portrait: Text('Portrait'),
            landscape: Text('Landscape'),
          ),
        ),
      );

      expect(find.text('Portrait'), findsOneWidget);
      expect(find.text('Landscape'), findsNothing);
    });

    testWidgets('shows landscape widget in landscape', (tester) async {
      tester.view.physicalSize = const Size(800, 400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        const MaterialApp(
          home: OrientationLayout(
            portrait: Text('Portrait'),
            landscape: Text('Landscape'),
          ),
        ),
      );

      expect(find.text('Portrait'), findsNothing);
      expect(find.text('Landscape'), findsOneWidget);
    });

    testWidgets('falls back to portrait when landscape is null', (tester) async {
      tester.view.physicalSize = const Size(800, 400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        const MaterialApp(
          home: OrientationLayout(
            portrait: Text('Portrait'),
          ),
        ),
      );

      expect(find.text('Portrait'), findsOneWidget);
    });
  });
}
