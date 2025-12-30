import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

class AppLogger {
  static void page(String pageName) {
    debugPrint('📄 PAGE → $pageName');
    developer.log(
      'PAGE → $pageName',
      name: 'NAVIGATION',
    );
  }

  static void action(String message) {
    debugPrint('⚡ ACTION → $message');
    developer.log(
      'ACTION → $message',
      name: 'ACTION',
    );
  }

  static void service(String service, String message) {
    debugPrint('🛠 $service → $message');
    developer.log(
      '$service → $message',
      name: 'SERVICE',
    );
  }

  static void error(String origin, Object error, StackTrace stack) {
    debugPrint('❌ ERROR → $origin → $error');
    developer.log(
      'ERROR → $origin → $error',
      name: 'ERROR',
      error: error,
      stackTrace: stack,
    );
  }
}
