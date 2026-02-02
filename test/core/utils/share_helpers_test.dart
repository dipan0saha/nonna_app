import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/core/utils/share_helpers.dart';

void main() {
  group('ShareHelpers', () {
    group('Deep Link Generation', () {
      test('generateProfileLink creates correct URL', () {
        final link = ShareHelpers.generateProfileLink('profile123');
        expect(link, 'https://nonna.app/profile/profile123');
      });

      test('generateEventLink creates correct URL', () {
        final link = ShareHelpers.generateEventLink('profile123', 'event456');
        expect(link, 'https://nonna.app/profile/profile123/event/event456');
      });

      test('generatePhotoLink creates correct URL', () {
        final link = ShareHelpers.generatePhotoLink('profile123', 'photo789');
        expect(link, 'https://nonna.app/profile/profile123/photo/photo789');
      });

      test('generateRegistryItemLink creates correct URL', () {
        final link =
            ShareHelpers.generateRegistryItemLink('profile123', 'item999');
        expect(link, 'https://nonna.app/profile/profile123/registry/item999');
      });

      test('generateInvitationLink creates correct URL', () {
        final link = ShareHelpers.generateInvitationLink('ABC123XYZ');
        expect(link, 'https://nonna.app/invite/ABC123XYZ');
      });

      test('deep links handle special characters in IDs', () {
        final link = ShareHelpers.generateProfileLink('profile-123_test');
        expect(link, contains('profile-123_test'));
      });
    });

    group('Share Text Generation', () {
      test('generateProfileShareText creates correct text', () {
        final text = ShareHelpers.generateProfileShareText('Emma');
        expect(text, 'Check out Emma\'s profile on Nonna! 👶');
      });

      test('generateEventShareText creates correct text', () {
        final eventDate = DateTime(2024, 12, 25, 10, 0);
        final text =
            ShareHelpers.generateEventShareText('Birthday Party', eventDate);
        expect(text, contains('You\'re invited to Birthday Party'));
        expect(text, contains('2024-12-25'));
        expect(text, contains('🎉'));
      });

      test('generatePhotoShareText creates text without caption', () {
        final text = ShareHelpers.generatePhotoShareText('Emma');
        expect(text, 'Check out this photo of Emma on Nonna! 📸');
      });

      test('generatePhotoShareText creates text with caption', () {
        final text = ShareHelpers.generatePhotoShareText(
          'Emma',
          caption: 'First steps!',
        );
        expect(text, 'First steps! - Emma on Nonna 📸');
      });

      test('generatePhotoShareText handles empty caption', () {
        final text = ShareHelpers.generatePhotoShareText(
          'Emma',
          caption: '',
        );
        expect(text, 'Check out this photo of Emma on Nonna! 📸');
      });

      test('generateRegistryShareText creates correct text', () {
        final text = ShareHelpers.generateRegistryShareText('Emma');
        expect(text, 'Check out Emma\'s registry on Nonna! 🎁');
      });

      test('generateInvitationText creates correct text', () {
        final text =
            ShareHelpers.generateInvitationText('Emma', 'Grandma Rose');
        expect(text,
            'Grandma Rose has invited you to follow Emma\'s journey on Nonna! 👶');
      });

      test('share text handles names with special characters', () {
        final text = ShareHelpers.generateProfileShareText('María José');
        expect(text, contains('María José'));
      });
    });

    group('Share Subject Lines', () {
      test('generateProfileSubject creates correct subject', () {
        final subject = ShareHelpers.generateProfileSubject('Emma');
        expect(subject, 'Emma on Nonna');
      });

      test('generateEventSubject creates correct subject', () {
        final subject = ShareHelpers.generateEventSubject('Baby Shower');
        expect(subject, 'You\'re invited: Baby Shower');
      });

      test('generateInvitationSubject creates correct subject', () {
        final subject = ShareHelpers.generateInvitationSubject('Emma');
        expect(subject, 'You\'re invited to follow Emma on Nonna');
      });

      test('subjects handle names with apostrophes', () {
        final subject = ShareHelpers.generateProfileSubject('O\'Brien');
        expect(subject, contains('O\'Brien'));
      });
    });

    group('Share Content Generation', () {
      test('generateShareContent combines text and link', () {
        final content = ShareHelpers.generateShareContent(
          text: 'Check this out!',
          link: 'https://nonna.app/profile/123',
        );

        expect(content, contains('Check this out!'));
        expect(content, contains('https://nonna.app/profile/123'));
        expect(content, contains('\n\n'));
      });

      test('formatForEmail creates formatted email content', () {
        final email = ShareHelpers.formatForEmail(
          subject: 'Test Subject',
          body: 'Test Body',
          link: 'https://nonna.app/test',
        );

        expect(email, contains('Subject: Test Subject'));
        expect(email, contains('Test Body'));
        expect(email, contains('https://nonna.app/test'));
        expect(email, contains('Sent from Nonna App'));
      });

      test('formatForSms creates concise SMS content', () {
        final sms = ShareHelpers.formatForSms(
          'Check this out!',
          'https://nonna.app/test',
        );

        expect(sms, 'Check this out! https://nonna.app/test');
        expect(sms.length, lessThan(200)); // SMS should be concise
      });

      test('formatForSocial creates social media content', () {
        final social = ShareHelpers.formatForSocial(
          'Check this out!',
          'https://nonna.app/test',
        );

        expect(social, contains('Check this out!'));
        expect(social, contains('https://nonna.app/test'));
      });

      test('formatForSocial includes hashtags', () {
        final social = ShareHelpers.formatForSocial(
          'Check this out!',
          'https://nonna.app/test',
          hashtags: ['baby', 'family'],
        );

        expect(social, contains('#baby'));
        expect(social, contains('#family'));
      });

      test('formatForSocial handles no hashtags', () {
        final social = ShareHelpers.formatForSocial(
          'Check this out!',
          'https://nonna.app/test',
          hashtags: [],
        );

        expect(social, isNot(contains('#')));
      });
    });

    group('Invitation Creation', () {
      test('createInvitation generates complete invitation data', () {
        final invitation = ShareHelpers.createInvitation(
          profileId: 'profile123',
          inviterName: 'John Doe',
          inviterEmail: 'john@example.com',
        );

        expect(invitation['profileId'], 'profile123');
        expect(invitation['inviterName'], 'John Doe');
        expect(invitation['inviterEmail'], 'john@example.com');
        expect(invitation['invitationCode'], isNotNull);
        expect(invitation['createdAt'], isNotNull);
        expect(invitation['expiresAt'], isNotNull);
      });

      test('createInvitation includes optional fields', () {
        final invitation = ShareHelpers.createInvitation(
          profileId: 'profile123',
          inviterName: 'John Doe',
          inviterEmail: 'john@example.com',
          recipientEmail: 'jane@example.com',
          recipientPhone: '+1234567890',
          personalMessage: 'Join us!',
        );

        expect(invitation['recipientEmail'], 'jane@example.com');
        expect(invitation['recipientPhone'], '+1234567890');
        expect(invitation['personalMessage'], 'Join us!');
      });

      test('createInvitation generates unique invitation codes', () {
        final invitation1 = ShareHelpers.createInvitation(
          profileId: 'profile123',
          inviterName: 'John Doe',
          inviterEmail: 'john@example.com',
        );

        // Wait a tiny bit to ensure different timestamp
        final invitation2 = ShareHelpers.createInvitation(
          profileId: 'profile123',
          inviterName: 'John Doe',
          inviterEmail: 'john@example.com',
        );

        expect(
          invitation1['invitationCode'],
          isNot(equals(invitation2['invitationCode'])),
        );
      });

      test('createInvitation sets expiration to 30 days', () {
        final invitation = ShareHelpers.createInvitation(
          profileId: 'profile123',
          inviterName: 'John Doe',
          inviterEmail: 'john@example.com',
        );

        final createdAt = DateTime.parse(invitation['createdAt'] as String);
        final expiresAt = DateTime.parse(invitation['expiresAt'] as String);
        final difference = expiresAt.difference(createdAt);

        expect(difference.inDays, 30);
      });
    });

    group('URL Helpers', () {
      test('parseDeepLink extracts profile ID', () {
        final params =
            ShareHelpers.parseDeepLink('https://nonna.app/profile/profile123');

        expect(params, isNotNull);
        expect(params!['profileId'], 'profile123');
      });

      test('parseDeepLink extracts event data', () {
        final params = ShareHelpers.parseDeepLink(
          'https://nonna.app/profile/profile123/event/event456',
        );

        expect(params, isNotNull);
        expect(params!['profileId'], 'profile123');
        expect(params['contentType'], 'event');
        expect(params['contentId'], 'event456');
      });

      test('parseDeepLink extracts photo data', () {
        final params = ShareHelpers.parseDeepLink(
          'https://nonna.app/profile/profile123/photo/photo789',
        );

        expect(params, isNotNull);
        expect(params!['profileId'], 'profile123');
        expect(params['contentType'], 'photo');
        expect(params['contentId'], 'photo789');
      });

      test('parseDeepLink extracts invitation code', () {
        final params =
            ShareHelpers.parseDeepLink('https://nonna.app/invite/ABC123XYZ');

        expect(params, isNotNull);
        expect(params!['invitationCode'], 'ABC123XYZ');
      });

      test('parseDeepLink extracts query parameters', () {
        final params = ShareHelpers.parseDeepLink(
          'https://nonna.app/profile/profile123?ref=email&campaign=summer',
        );

        expect(params, isNotNull);
        expect(params!['profileId'], 'profile123');
        expect(params['ref'], 'email');
        expect(params['campaign'], 'summer');
      });

      test('parseDeepLink returns null for invalid URL', () {
        expect(ShareHelpers.parseDeepLink('not a url'), null);
        expect(ShareHelpers.parseDeepLink(''), null);
      });

      test('parseDeepLink returns null for URL without relevant paths', () {
        expect(ShareHelpers.parseDeepLink('https://nonna.app/'), null);
        expect(ShareHelpers.parseDeepLink('https://nonna.app/about'), null);
      });

      test('isValidDeepLink validates correct URLs', () {
        expect(
          ShareHelpers.isValidDeepLink('https://nonna.app/profile/123'),
          true,
        );
        expect(
          ShareHelpers.isValidDeepLink('http://nonna.app/invite/ABC'),
          true,
        );
      });

      test('isValidDeepLink rejects invalid URLs', () {
        expect(ShareHelpers.isValidDeepLink('not a url'), false);
        expect(ShareHelpers.isValidDeepLink(''), false);
        expect(ShareHelpers.isValidDeepLink('nonna.app'), false);
      });
    });

    group('Track Methods (No-op)', () {
      test('trackShare does not throw', () {
        expect(
          () => ShareHelpers.trackShare(
            contentType: 'profile',
            contentId: '123',
            shareMethod: 'email',
          ),
          returnsNormally,
        );
      });

      test('trackInvitationSent does not throw', () {
        expect(
          () => ShareHelpers.trackInvitationSent(
            profileId: '123',
            method: 'sms',
          ),
          returnsNormally,
        );
      });
    });

    group('UnimplementedError Methods', () {
      test('shareText throws UnimplementedError', () async {
        expect(
          () async => await ShareHelpers.shareText('Test'),
          throwsA(isA<UnimplementedError>()),
        );
      });

      test('shareLink throws UnimplementedError', () async {
        expect(
          () async =>
              await ShareHelpers.shareLink('https://nonna.app/test'),
          throwsA(isA<UnimplementedError>()),
        );
      });

      test('shareToApp throws UnimplementedError', () async {
        expect(
          () async => await ShareHelpers.shareToApp('Test', 'whatsapp'),
          throwsA(isA<UnimplementedError>()),
        );
      });
    });

    group('Edge Cases', () {
      test('handles empty strings', () {
        expect(ShareHelpers.generateProfileLink(''), 'https://nonna.app/profile/');
        expect(ShareHelpers.generateProfileShareText(''), contains('\'s profile'));
      });

      test('handles very long names', () {
        final longName = 'A' * 100;
        final text = ShareHelpers.generateProfileShareText(longName);
        expect(text, contains(longName));
      });

      test('handles special characters in names', () {
        final names = ['José', 'François', 'Müller', 'O\'Brien'];
        for (final name in names) {
          final text = ShareHelpers.generateProfileShareText(name);
          expect(text, contains(name));
        }
      });

      test('parseDeepLink handles malformed URLs gracefully', () {
        expect(ShareHelpers.parseDeepLink('http://'), null);
        expect(ShareHelpers.parseDeepLink('https://'), null);
        expect(ShareHelpers.parseDeepLink('://nonna.app'), null);
      });

      test('formatForEmail handles multi-line content', () {
        final email = ShareHelpers.formatForEmail(
          subject: 'Test\nSubject',
          body: 'Test\nBody\nWith\nLines',
          link: 'https://nonna.app/test',
        );

        expect(email, contains('Test\nSubject'));
        expect(email, contains('Test\nBody\nWith\nLines'));
      });
    });

    group('Integration Scenarios', () {
      test('complete profile sharing flow', () {
        // Generate link
        final link = ShareHelpers.generateProfileLink('baby123');

        // Generate text
        final text = ShareHelpers.generateProfileShareText('Emma');

        // Generate subject
        final subject = ShareHelpers.generateProfileSubject('Emma');

        // Combine for share
        final content = ShareHelpers.generateShareContent(
          text: text,
          link: link,
        );

        expect(link, contains('baby123'));
        expect(text, contains('Emma'));
        expect(subject, contains('Emma'));
        expect(content, contains(text));
        expect(content, contains(link));
      });

      test('complete event invitation flow', () {
        final eventDate = DateTime(2024, 12, 25);
        final link = ShareHelpers.generateEventLink('baby123', 'event456');
        final text =
            ShareHelpers.generateEventShareText('Baby Shower', eventDate);
        final subject = ShareHelpers.generateEventSubject('Baby Shower');

        final email = ShareHelpers.formatForEmail(
          subject: subject,
          body: text,
          link: link,
        );

        expect(email, contains('Baby Shower'));
        expect(email, contains(link));
      });

      test('complete invitation creation flow', () {
        final invitation = ShareHelpers.createInvitation(
          profileId: 'baby123',
          inviterName: 'John',
          inviterEmail: 'john@example.com',
          recipientEmail: 'jane@example.com',
        );

        final code = invitation['invitationCode'] as String;
        final link = ShareHelpers.generateInvitationLink(code);
        final text = ShareHelpers.generateInvitationText('Emma', 'John');

        expect(link, contains(code));
        expect(text, contains('Emma'));
        expect(text, contains('John'));
      });
    });
  });
}
