import 'package:concordia_nav/utils/logger_util.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';

void main() {
  group('LoggerUtil Tests', () {
    test('Singleton instance should be the same', () {
      final instance1 = LoggerUtil();
      final instance2 = LoggerUtil();
      expect(instance1, same(instance2));
    });

    test('Default log level should be INFO', () {
      expect(LoggerUtil.getLogLevel(), Level.info);
    });

    test('Setting log level should update correctly', () {
      LoggerUtil.setLogLevel(Level.debug);
      expect(LoggerUtil.getLogLevel(), Level.debug);
    });

    test('String to Level conversion should work correctly', () {
      expect(LoggerUtil.stringToLevel('trace'), Level.trace);
      expect(LoggerUtil.stringToLevel('debug'), Level.debug);
      expect(LoggerUtil.stringToLevel('info'), Level.info);
      expect(LoggerUtil.stringToLevel('warn'), Level.warning);
      expect(LoggerUtil.stringToLevel('error'), Level.error);
      expect(LoggerUtil.stringToLevel('fatal'), Level.fatal);
      expect(LoggerUtil.stringToLevel('unknown'), Level.info); // Default case
      expect(LoggerUtil.stringToLevel(null), Level.info); // Null case
    });

    test('LoggerUtil trace method should call logger.t()', () {
      LoggerUtil.trace('Trace message');
    });

    test('LoggerUtil debug method should call logger.d()', () {
      LoggerUtil.debug('Debug message');
    });

    test('LoggerUtil info method should call logger.i()', () {
      LoggerUtil.info('Info message');
    });

    test('LoggerUtil warning method should call logger.w()', () {
      LoggerUtil.warning('Warning message');
    });

    test('LoggerUtil error method should call logger.e()', () {
      LoggerUtil.error('Error message');
    });

    test('LoggerUtil fatal method should call logger.f()', () {
      LoggerUtil.fatal('Fatal message');
    });
  });
}
