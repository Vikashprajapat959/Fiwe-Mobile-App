import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class Helper {
  // convert base64 string to bytes
  static Uint8List? base64ToBytes(String? base64String) {
    if (base64String == null || base64String.isEmpty) return null;
    try {
      final base64Str = base64String.split(';base64,').last;
      return Base64Decoder().convert(base64Str);
    } catch (e) {
      return null;
    }
  }

  static Future<String> imageFileToBase64(XFile pickedFile) {
    return compute((XFile file) async {
      final bytes = await file.readAsBytes();
      return base64Encode(bytes);
    }, pickedFile);
  }
}
