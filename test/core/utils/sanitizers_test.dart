import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/core/utils/sanitizers.dart';

void main() {
  group('Sanitizers', () {
    group('encodeHtml', () {
      test('encodes HTML special characters', () {
        expect(Sanitizers.encodeHtml('<script>'), '&lt;script&gt;');
        expect(Sanitizers.encodeHtml('a & b'), 'a &amp; b');
        expect(Sanitizers.encodeHtml('"test"'), '&quot;test&quot;');
      });
    });

    group('stripHtmlTags', () {
      test('removes HTML tags', () {
        expect(Sanitizers.stripHtmlTags('<p>Hello</p>'), 'Hello');
        expect(Sanitizers.stripHtmlTags('<b>Bold</b> text'), 'Bold text');
      });
    });

    group('sanitizeHtml', () {
      test('strips tags and encodes special characters', () {
        expect(Sanitizers.sanitizeHtml('<script>alert("xss")</script>'),
            'alert(&quot;xss&quot;)');
      });
    });

    group('removeScriptTags', () {
      test('removes script tags and content', () {
        final input = 'Hello <script>alert("xss")</script> World';
        expect(Sanitizers.removeScriptTags(input), 'Hello  World');
      });
    });

    group('trim', () {
      test('trims whitespace', () {
        expect(Sanitizers.trim('  hello  '), 'hello');
        expect(Sanitizers.trim('\n\ttest\t\n'), 'test');
      });
    });

    group('removeExtraWhitespace', () {
      test('removes extra whitespace', () {
        expect(
            Sanitizers.removeExtraWhitespace('hello    world'), 'hello world');
        expect(Sanitizers.removeExtraWhitespace('  a  b  c  '), 'a b c');
      });
    });

    group('removeAllWhitespace', () {
      test('removes all whitespace', () {
        expect(Sanitizers.removeAllWhitespace('hello world'), 'helloworld');
        expect(Sanitizers.removeAllWhitespace('a b c'), 'abc');
      });
    });

    group('removeSpecialCharacters', () {
      test('removes special characters', () {
        expect(
            Sanitizers.removeSpecialCharacters('hello!@#world'), 'helloworld');
        expect(Sanitizers.removeSpecialCharacters('test-123'), 'test123');
      });
    });

    group('sanitizeUrl', () {
      test('blocks dangerous URL schemes', () {
        expect(Sanitizers.sanitizeUrl('javascript:alert("xss")'), '');
        expect(Sanitizers.sanitizeUrl('data:text/html,<script>'), '');
      });

      test('allows safe URLs', () {
        expect(Sanitizers.sanitizeUrl('https://example.com'),
            'https://example.com');
        expect(
            Sanitizers.sanitizeUrl('http://example.com'), 'http://example.com');
      });

      test('adds https:// to URLs without protocol', () {
        expect(Sanitizers.sanitizeUrl('example.com'), 'https://example.com');
      });
    });

    group('sanitizeEmail', () {
      test('sanitizes email addresses', () {
        expect(
            Sanitizers.sanitizeEmail('Test@Example.Com'), 'test@example.com');
        expect(
            Sanitizers.sanitizeEmail('  user@domain.com  '), 'user@domain.com');
      });

      test('removes dangerous characters', () {
        expect(
            Sanitizers.sanitizeEmail('test;@example.com'), 'test@example.com');
      });
    });

    group('sanitizeFileName', () {
      test('removes path separators', () {
        expect(Sanitizers.sanitizeFileName('../../../etc/passwd'), 'etcpasswd');
        expect(Sanitizers.sanitizeFileName('test/file.txt'), 'testfile.txt');
      });

      test('removes leading dots', () {
        expect(Sanitizers.sanitizeFileName('.hidden'), 'hidden');
        expect(Sanitizers.sanitizeFileName('...test'), 'test');
      });

      test('removes dangerous characters', () {
        expect(Sanitizers.sanitizeFileName('file:name'), 'filename');
        expect(Sanitizers.sanitizeFileName('file*name'), 'filename');
      });
    });

    group('sanitizePhoneNumber', () {
      test('removes non-digit characters', () {
        expect(Sanitizers.sanitizePhoneNumber('(555) 123-4567'), '5551234567');
        expect(
            Sanitizers.sanitizePhoneNumber('+1-555-123-4567'), '15551234567');
      });
    });

    group('sanitizeCreditCard', () {
      test('removes non-digit characters', () {
        expect(Sanitizers.sanitizeCreditCard('1234-5678-9012-3456'),
            '1234567890123456');
        expect(Sanitizers.sanitizeCreditCard('1234 5678 9012 3456'),
            '1234567890123456');
      });
    });

    group('sanitizeText', () {
      test('applies multiple sanitization options', () {
        final result = Sanitizers.sanitizeText(
          '  hello   world  ',
          trimWhitespace: true,
          removeExtraSpaces: true,
        );
        expect(result, 'hello world');
      });
    });

    group('truncate', () {
      test('truncates long strings', () {
        expect(Sanitizers.truncate('hello world', 5), 'hello');
      });

      test('does not truncate short strings', () {
        expect(Sanitizers.truncate('hi', 5), 'hi');
      });
    });
  });
}
