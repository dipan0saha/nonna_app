import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:nonna_app/features/auth/presentation/providers/auth_state.dart';
import 'package:nonna_app/features/home/presentation/widgets/home_app_bar.dart';

// ---------------------------------------------------------------------------
// Fake AuthNotifier — returns a static unauthenticated state without touching
// Supabase or any other service provider.
// ---------------------------------------------------------------------------
class _FakeAuthNotifier extends AuthNotifier {
  @override
  AuthState build() => const AuthState.unauthenticated();
}

Widget _buildAppBar({VoidCallback? onBabyProfileTap}) {
  return ProviderScope(
    overrides: [
      authProvider.overrideWith(_FakeAuthNotifier.new),
    ],
    child: MaterialApp(
      home: Scaffold(
        appBar: HomeAppBar(onBabyProfileTap: onBabyProfileTap),
        body: const SizedBox.shrink(),
      ),
    ),
  );
}

void main() {
  group('HomeAppBar', () {
    testWidgets('renders with key home_app_bar', (tester) async {
      await tester.pumpWidget(_buildAppBar());
      expect(find.byKey(const Key('home_app_bar')), findsOneWidget);
    });

    testWidgets('always shows Nonna as the title', (tester) async {
      await tester.pumpWidget(_buildAppBar());
      expect(find.text('Nonna'), findsOneWidget);
    });

    testWidgets('renders search icon button in the leading position',
        (tester) async {
      await tester.pumpWidget(_buildAppBar());
      expect(find.byKey(const Key('search_icon_button')), findsOneWidget);
    });

    testWidgets('renders profile avatar button in the actions', (tester) async {
      await tester.pumpWidget(_buildAppBar());
      expect(find.byKey(const Key('profile_avatar_button')), findsOneWidget);
    });

    testWidgets('calls onBabyProfileTap when avatar button is tapped',
        (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        _buildAppBar(onBabyProfileTap: () => tapped = true),
      );
      await tester.tap(find.byKey(const Key('profile_avatar_button')));
      expect(tapped, isTrue);
    });
  });
}
