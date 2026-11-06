import 'dart:convert';

/// String extensions for common operations
extension StringExtensions on String {
  /// Capitalizes the first letter of the string
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }

  /// Capitalizes the first letter of each word
  String capitalizeWords() {
    if (isEmpty) return this;
    return split(' ')
        .map((String word) => word.isEmpty ? word : word.capitalize())
        .join(' ');
  }

  /// Converts string to camelCase
  String toCamelCase() {
    if (isEmpty) return this;
    final words = split(RegExp(r'[\s_-]+'));
    if (words.isEmpty) return this;
    
    return words.first.toLowerCase() +
        words.skip(1).map((String word) => word.capitalize()).join();
  }

  /// Parses the string as JSON
  Map<String, dynamic> toJson() => json.decode(this) as Map<String, dynamic>;

  /// Checks if the string is a valid email
  bool get isValidEmail {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);
  }

  /// Checks if the string is a valid phone number
  bool get isValidPhoneNumber {
    return RegExp(r'^\+?[1-9]\d{1,14}$').hasMatch(this);
  }

  /// Removes extra whitespaces and trims the string
  String get cleaned {
    return trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Truncates the string to the specified length
  String truncate(int maxLength, {String suffix = '...'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}$suffix';
  }
}

/// Nullable string extensions
extension NullableStringExtensions on String? {
  /// Checks if the string is null or empty
  bool get isNullOrEmpty => this == null || this!.isEmpty;

  /// Checks if the string is not null and not empty
  bool get isNotNullOrEmpty => !isNullOrEmpty;

  /// Returns the string or a default value if null or empty
  String orDefault(String defaultValue) {
    return isNullOrEmpty ? defaultValue : this!;
  }
}

/// DateTime extensions for formatting
extension DateTimeExtensions on DateTime {
  /// Formats the date as a readable string
  String get formatted {
    return '${day.toString().padLeft(2, '0')}/${month.toString().padLeft(2, '0')}/$year';
  }

  /// Formats the time as a readable string
  String get timeFormatted {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  /// Returns a relative time string (e.g., "2 hours ago")
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }
}

/// List extensions for common operations
extension ListExtensions<T> on List<T> {
  /// Safely gets an element at the specified index
  T? safeGet(int index) {
    if (index < 0 || index >= length) return null;
    return this[index];
  }

  /// Chunks the list into smaller lists of the specified size
  List<List<T>> chunk(int size) {
    if (size <= 0) throw ArgumentError('Size must be positive');
    
    final result = <List<T>>[];
    for (int i = 0; i < length; i += size) {
      result.add(sublist(i, (i + size > length) ? length : i + size));
    }
    return result;
  }
}
