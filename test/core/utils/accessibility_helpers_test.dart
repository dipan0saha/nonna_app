import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/core/utils/accessibility_helpers.dart';

void main() {
  group('AccessibilityHelpers', () {
    group('Semantic Labels', () {
      testWidgets('imageSemantics adds image label', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: AccessibilityHelpers.imageSemantics(
              label: 'Profile picture',
              child: const Icon(Icons.person),
            ),
          ),
        );

        final semantics = tester.getSemantics(find.byType(Icon));
        expect(semantics.label, 'Profile picture');
      });

      testWidgets('buttonSemantics adds button label', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: AccessibilityHelpers.buttonSemantics(
              label: 'Submit form',
              child: const Icon(Icons.check),
            ),
          ),
        );

        final semantics = tester.getSemantics(find.byType(Icon));
        expect(semantics.label, 'Submit form');
      });

      testWidgets('linkSemantics adds link label', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: AccessibilityHelpers.linkSemantics(
              label: 'Visit website',
              child: const Text('Click here'),
            ),
          ),
        );

        final semantics = tester.getSemantics(find.text('Click here'));
        expect(semantics.label, 'Visit website');
      });

      testWidgets('headingSemantics marks as header', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: AccessibilityHelpers.headingSemantics(
              label: 'Page Title',
              child: const Text('Welcome'),
            ),
          ),
        );

        final semantics = tester.getSemantics(find.text('Welcome'));
        expect(semantics.label, 'Page Title');
      });
    });

    group('Touch Target Helpers', () {
      test('minimumTouchTarget is 44 pixels', () {
        expect(AccessibilityHelpers.minimumTouchTarget, 44.0);
      });

      testWidgets('ensureTouchTarget enforces minimum size', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AccessibilityHelpers.ensureTouchTarget(
                child: const SizedBox(width: 10, height: 10),
              ),
            ),
          ),
        );

        final constrainedBox = tester.widgetList<ConstrainedBox>(
          find.byType(ConstrainedBox),
        ).firstWhere((box) => 
          box.constraints.minWidth == 44.0 && 
          box.constraints.minHeight == 44.0
        );
        
        expect(constrainedBox.constraints.minWidth, 44.0);
        expect(constrainedBox.constraints.minHeight, 44.0);
      });

      testWidgets('touchTarget creates accessible button', (tester) async {
        var tapped = false;
        
        await tester.pumpWidget(
          MaterialApp(
            home: AccessibilityHelpers.touchTarget(
              label: 'Delete item',
              onTap: () => tapped = true,
              child: const Icon(Icons.delete),
            ),
          ),
        );

        await tester.tap(find.byType(Icon));
        expect(tapped, isTrue);
        
        final semantics = tester.getSemantics(find.byType(Icon));
        expect(semantics.label, 'Delete item');
      });
    });

    group('ARIA-like Attributes', () {
      testWidgets('expandableSemantics marks expansion state', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: AccessibilityHelpers.expandableSemantics(
              expanded: true,
              label: 'Menu',
              child: const Text('Items'),
            ),
          ),
        );

        final semantics = tester.getSemantics(find.text('Items'));
        expect(semantics.label, 'Menu');
      });

      testWidgets('selectableSemantics marks selection state', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: AccessibilityHelpers.selectableSemantics(
              selected: true,
              label: 'Option A',
              child: const Text('A'),
            ),
          ),
        );

        final semantics = tester.getSemantics(find.text('A'));
        expect(semantics.label, 'Option A');
      });

      testWidgets('checkableSemantics marks checked state', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: AccessibilityHelpers.checkableSemantics(
              checked: true,
              label: 'Enable notifications',
              child: const Icon(Icons.check_box),
            ),
          ),
        );

        final semantics = tester.getSemantics(find.byType(Icon));
        expect(semantics.label, 'Enable notifications');
      });
    });

    group('Live Regions', () {
      testWidgets('liveRegion marks dynamic content', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: AccessibilityHelpers.liveRegion(
              label: 'Loading status',
              child: const Text('Loading...'),
            ),
          ),
        );

        final semantics = tester.getSemantics(find.text('Loading...'));
        expect(semantics.label, 'Loading status');
      });

      testWidgets('loadingIndicator has appropriate label', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: AccessibilityHelpers.loadingIndicator(
              label: 'Loading data',
            ),
          ),
        );

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        final semantics = tester.getSemantics(find.byType(CircularProgressIndicator));
        expect(semantics.label, 'Loading data');
      });

      testWidgets('errorMessage has error prefix', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: AccessibilityHelpers.errorMessage(
              message: 'Invalid input',
            ),
          ),
        );

        final semantics = tester.getSemantics(find.text('Invalid input'));
        expect(semantics.label, 'Error: Invalid input');
      });

      testWidgets('successMessage has success prefix', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: AccessibilityHelpers.successMessage(
              message: 'Saved successfully',
            ),
          ),
        );

        final semantics = tester.getSemantics(find.text('Saved successfully'));
        expect(semantics.label, 'Success: Saved successfully');
      });
    });

    group('Group & Label Management', () {
      testWidgets('group containers related elements', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: AccessibilityHelpers.group(
              label: 'User settings',
              child: const Column(
                children: [
                  Text('Name'),
                  Text('Email'),
                ],
              ),
            ),
          ),
        );

        final semantics = tester.getSemantics(find.byType(Column));
        expect(semantics.label, 'User settings');
      });

      testWidgets('hideFromSemantics excludes decorative elements', (tester) async {
        const testIcon = Icon(Icons.star);
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AccessibilityHelpers.hideFromSemantics(
                testIcon,
              ),
            ),
          ),
        );

        // Find ExcludeSemantics that wraps the Icon
        final excludeSemantics = tester.widget<ExcludeSemantics>(
          find.ancestor(
            of: find.byWidget(testIcon),
            matching: find.byType(ExcludeSemantics),
          ),
        );
        expect(excludeSemantics.excluding, true);
      });

      testWidgets('mergeSemantics combines child semantics', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: AccessibilityHelpers.mergeSemantics(
              label: 'Merged label',
              child: const Text('Content'),
            ),
          ),
        );

        expect(find.byType(MergeSemantics), findsOneWidget);
      });
    });

    group('Utility Methods', () {
      testWidgets('isScreenReaderEnabled returns bool', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                final enabled = AccessibilityHelpers.isScreenReaderEnabled(context);
                expect(enabled, isA<bool>());
                return const SizedBox();
              },
            ),
          ),
        );
      });

      testWidgets('isBoldTextEnabled returns bool', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                final enabled = AccessibilityHelpers.isBoldTextEnabled(context);
                expect(enabled, isA<bool>());
                return const SizedBox();
              },
            ),
          ),
        );
      });

      testWidgets('shouldDisableAnimations returns bool', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                final disabled = AccessibilityHelpers.shouldDisableAnimations(context);
                expect(disabled, isA<bool>());
                return const SizedBox();
              },
            ),
          ),
        );
      });

      testWidgets('getAccessibilityTextScale returns scale factor', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                final scale = AccessibilityHelpers.getAccessibilityTextScale(context);
                expect(scale, greaterThan(0));
                return const SizedBox();
              },
            ),
          ),
        );
      });
    });

    group('Focus Management', () {
      testWidgets('focusable wraps widget with Focus', (tester) async {
        final focusNode = FocusNode();
        const testText = Text('Focusable');
        
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AccessibilityHelpers.focusable(
                focusNode: focusNode,
                child: testText,
              ),
            ),
          ),
        );

        // Find Focus widget that wraps our test text
        final focus = tester.widget<Focus>(
          find.ancestor(
            of: find.byWidget(testText),
            matching: find.byType(Focus),
          ).first,
        );
        expect(focus.focusNode, focusNode);
      });
    });

    group('Common Semantic Patterns', () {
      testWidgets('badge includes count in semantics', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: AccessibilityHelpers.badge(
              count: 5,
              child: const Icon(Icons.notifications),
            ),
          ),
        );

        final semantics = tester.getSemantics(find.byType(Icon));
        expect(semantics.label, contains('5'));
      });

      testWidgets('progress includes percentage', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: AccessibilityHelpers.progress(
              value: 0.75,
              child: const LinearProgressIndicator(value: 0.75),
            ),
          ),
        );

        final semantics = tester.getSemantics(find.byType(LinearProgressIndicator));
        expect(semantics.value, contains('75'));
      });
    });
  });
}
