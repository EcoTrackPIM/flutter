import 'package:logger/logger.dart';

class LoggerService {
  static final Logger _logger = Logger();

  static void info(String message) {
    _logger.i(message);
  }

  static void warning(String message) {
    _logger.w(message);
  }

  static void error(String message) {
    _logger.e(message);
  }

  static void debug(String message) {
    _logger.d(message);
  }
}
