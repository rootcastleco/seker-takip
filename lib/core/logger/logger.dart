import 'dart:async';
import 'file_log_sink.dart';
import 'pii_mask.dart';

/// Log seviyeleri.
enum LogLevel { debug, info, warn, error, fatal }

/// Uygulama geneli logger. Singleton.
class AppLogger {
  AppLogger._();
  static final AppLogger instance = AppLogger._();

  FileLogSink? _sink;
  bool _initialized = false;
  bool maskPiiEnabled = true;

  Future<void> init(String logDir) async {
    _sink = FileLogSink(logDir);
    await _sink!.init();
    _initialized = true;
  }

  void log(LogLevel level, String message, {Object? error, StackTrace? stack}) {
    final timestamp = DateTime.now().toIso8601String();
    final levelStr = level.name.toUpperCase();
    var logMessage = '[$timestamp] $levelStr: $message';
    if (maskPiiEnabled) {
      logMessage = maskPii(logMessage);
    }
    if (error != null) {
      logMessage += '\n  ERROR: $error';
    }
    if (stack != null) {
      logMessage += '\n  STACK: $stack';
    }

    // Dosyaya yaz (fire-and-forget)
    if (_initialized) {
      unawaited(_sink!.write(logMessage));
    }
  }

  void debug(String message) => log(LogLevel.debug, message);
  void info(String message) => log(LogLevel.info, message);
  void warn(String message) => log(LogLevel.warn, message);
  void error(String message, {Object? error, StackTrace? stack}) =>
      log(LogLevel.error, message, error: error, stack: stack);
  void fatal(String message, {Object? error, StackTrace? stack}) =>
      log(LogLevel.fatal, message, error: error, stack: stack);

  Future<List<String>> getRecentLines(int count) async {
    if (!_initialized) return [];
    return _sink!.readLastLines(count);
  }

  Future<String> getAllLogs() async {
    if (!_initialized) return '';
    return _sink!.readAll();
  }

  Future<void> dispose() async {
    await _sink?.dispose();
  }
}
