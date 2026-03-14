import 'package:flutter/foundation.dart';

class Logger {
  static void debug(String message) {
    if (kDebugMode) {
      // ignore: avoid_print
      print('[DEBUG] $message');
    }
  }

  static void info(String message) {
    if (kDebugMode) {
      // ignore: avoid_print
      print('[INFO] $message');
    }
  }

  static void error(String message, [Object? error]) {
    if (kDebugMode) {
      // ignore: avoid_print
      print('[ERROR] $message');
      if (error != null) {
        // ignore: avoid_print
        print('[ERROR] Details: $error');
      }
    }
  }

  static void warn(String message) {
    if (kDebugMode) {
      // ignore: avoid_print
      print('[WARN] $message');
    }
  }
}
