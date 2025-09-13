import 'dart:convert';

extension StringExtensions on String {
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }

  Map<String, dynamic> toJson() => json.decode(this);
}
