import 'package:flutter/services.dart';

class CallHelper {
  static const MethodChannel _channel = MethodChannel('direct.call.channel');

  static Future<void> makeDirectCall(String phoneNumber) async {
    try {
      await _channel
          .invokeMethod('makeDirectCall', {'phoneNumber': phoneNumber});
    } on PlatformException catch (e) {
      print("Failed to make call: ${e.message}");
    }
  }
}
