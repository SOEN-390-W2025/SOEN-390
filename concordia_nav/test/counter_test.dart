//  In general, test files should reside inside a test folder located at the root of your Flutter application or package.
//  Test files should always end with _test.dart, this is the convention used by the test runner when searching for tests.

import 'package:concordia_nav/counter.dart';
import 'package:test/test.dart';

void main() {
  group('Test start, increment, decrement:', () {
    test('value should start at 0', () {
      expect(CounterTest().value, 0);
    });

    test('value should be incremented', () {
      final counter = CounterTest();

      counter.increment();
      expect(counter.value, 1);
    });

    test('value should be decremented', () {
      final counter = CounterTest();

      counter.decrement();
      expect(counter.value, -1);
    });
  });
}
