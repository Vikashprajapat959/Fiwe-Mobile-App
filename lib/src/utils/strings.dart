class Strings {
  // Example string values
  static const String appName = 'Fiwe App';
  static const String welcomeMessage = 'Welcome to Fiwe!';
  static const String errorMessage = 'Something went wrong. Please try again.';

  // Add more string constants as needed

  // Optional: Helper method to capitalize a string
  static String capitalize(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
  }
}
