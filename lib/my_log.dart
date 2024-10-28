import 'package:flutter/foundation.dart';

class MyLog {

  final String tag;

  MyLog(this.tag);

  void log(String message) {
    if (kDebugMode) {
      print('[$tag] $message');
    }
  }

}