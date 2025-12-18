import 'package:test/test.dart';

void main() {
  group('Unit Tests', () {
    test('String.split() splits the string on the delimiter', () {
      var string = 'foo,bar,baz';
      expect(string.split(','), equals(['foo', 'bar', 'baz']));
    });

    test('String.trim() removes surrounding whitespace', () {
      var string = '  foo ';
      expect(string.trim(), equals('foo'));
    });

    // Add more unit tests here for your business logic, utilities, etc.
    // For example, if you have a repository class, test its methods.
  });
}
