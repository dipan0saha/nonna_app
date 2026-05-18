import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/core/models/event.dart';
import 'package:nonna_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:nonna_app/features/auth/presentation/providers/auth_state.dart';
import 'package:nonna_app/features/calendar/presentation/screens/event_detail_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show User;

Event _makeEvent({
  String title = 'Baby Shower',
  String? description,
  String? location,
  String? videoLink,
  DateTime? endsAt,
}) {
  final now = DateTime(2024, 6, 15, 14, 0);
  return Event(
    id: 'event-1',
    babyProfileId: 'baby-1',
    createdByUserId: 'user-1',
    title: title,
    startsAt: now,
    endsAt: endsAt,
    description: description,
    location: location,
    videoLink: videoLink,
    createdAt: now,
    updatedAt: now,
  );
}

// Returns unauthenticated state — no user, buttons hidden
class _FakeUnauthNotifier extends AuthNotifier {
  @override
  AuthState build() => const AuthState.unauthenticated();
}

// Returns authenticated state as the event owner (user-1 == createdByUserId)
class _FakeOwnerNotifier extends AuthNotifier {
  @override
  AuthState build() => AuthState(
        status: AuthStatus.authenticated,
        user: User.fromJson({
          'id': 'user-1',
          'app_metadata': <String, dynamic>{},
          'user_metadata': <String, dynamic>{},
          'aud': 'authenticated',
          'created_at': '2024-01-01T00:00:00.000Z',
        }),
        session: null,
      );
}

Widget _buildScreen(
  Event event, {
  AuthNotifier Function()? authOverride,
}) {
  return ProviderScope(
    overrides: [
      authProvider.overrideWith(authOverride ?? _FakeUnauthNotifier.new),
    ],
    child: MaterialApp(
      home: EventDetailScreen(event: event),
    ),
  );
}

void main() {
  group('EventDetailScreen', () {
    testWidgets("renders Scaffold with key 'event_detail_screen'",
        (tester) async {
      await tester.pumpWidget(_buildScreen(_makeEvent()));
      await tester.pump();
      expect(find.byKey(const Key('event_detail_screen')), findsOneWidget);
    });

    testWidgets('shows event title', (tester) async {
      await tester.pumpWidget(_buildScreen(_makeEvent(title: 'Baby Shower')));
      await tester.pump();
      expect(find.byKey(const Key('event_title_text')), findsOneWidget);
      expect(find.text('Baby Shower'), findsWidgets);
    });

    testWidgets('shows description when provided', (tester) async {
      await tester
          .pumpWidget(_buildScreen(_makeEvent(description: 'Bring gifts!')));
      await tester.pump();
      expect(find.byKey(const Key('event_description_text')), findsOneWidget);
    });

    testWidgets('shows location row when location is set', (tester) async {
      await tester
          .pumpWidget(_buildScreen(_makeEvent(location: 'Central Park')));
      await tester.pump();
      expect(find.byKey(const Key('event_location_row')), findsOneWidget);
    });

    testWidgets('hides location row when location is null', (tester) async {
      await tester.pumpWidget(_buildScreen(_makeEvent()));
      await tester.pump();
      expect(find.byKey(const Key('event_location_row')), findsNothing);
    });

    testWidgets('shows edit and delete buttons for owner', (tester) async {
      await tester.pumpWidget(
        _buildScreen(_makeEvent(), authOverride: _FakeOwnerNotifier.new),
      );
      await tester.pump();
      expect(find.byKey(const Key('edit_event_button')), findsOneWidget);
      expect(find.byKey(const Key('delete_event_button')), findsOneWidget);
    });

    testWidgets('hides edit and delete buttons for non-owner', (tester) async {
      await tester.pumpWidget(
        _buildScreen(_makeEvent(), authOverride: _FakeUnauthNotifier.new),
      );
      await tester.pump();
      expect(find.byKey(const Key('edit_event_button')), findsNothing);
      expect(find.byKey(const Key('delete_event_button')), findsNothing);
    });
  });
}
