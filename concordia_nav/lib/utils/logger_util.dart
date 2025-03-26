import 'package:logger/logger.dart';

/// A singleton logger utior the entire application.
class LoggerUtil {
  // Private constructor
  LoggerUtil._();

  // Singleton instance
  static final LoggerUtil _instance = LoggerUtil._();

  // Current log level
  static Level _level = Level.info;

  // Factory constructor to return the singleton instance
  factory LoggerUtil() => _instance;

  // Logger instance with custom configuration
  static final Logger _logger = Logger(
    level: _level,
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.dateAndTime,
    ),
    output: ConsoleOutput(),
  );

  /// Sets the log level for the logger
  static void setLogLevel(Level level) {
    _level = level;
    Logger.level = level;
  }

  /// Gets the current log level
  static Level getLogLevel() => _level;

  // Proxy methods to the logger instance
  static void trace(dynamic message, [dynamic error, StackTrace? stackTrace]) =>
      _logger.t(message, error: error, stackTrace: stackTrace);

  static void debug(dynamic message, [dynamic error, StackTrace? stackTrace]) =>
      _logger.d(message, error: error, stackTrace: stackTrace);

  static void info(dynamic message, [dynamic error, StackTrace? stackTrace]) =>
      _logger.i(message, error: error, stackTrace: stackTrace);

  static void warning(dynamic message,
          [dynamic error, StackTrace? stackTrace]) =>
      _logger.w(message, error: error, stackTrace: stackTrace);

  static void error(dynamic message, [dynamic error, StackTrace? stackTrace]) =>
      _logger.e(message, error: error, stackTrace: stackTrace);

  static void fatal(dynamic message, [dynamic error, StackTrace? stackTrace]) =>
      _logger.f(message, error: error, stackTrace: stackTrace);

  static Level stringToLevel(String? levelName) {
    if (levelName == null) return Level.info;

    switch (levelName.toLowerCase()) {
      case 'verbose':
      case 'trace':
        return Level.trace;
      case 'debug':
        return Level.debug;
      case 'info':
        return Level.info;
      case 'warning':
      case 'warn':
        return Level.warning;
      case 'error':
        return Level.error;
      case 'fatal':
      case 'wtf':
        return Level.fatal;
      default:
        return Level.info;
    }
  }
}
