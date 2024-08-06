import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  static const String _keyKeepSignedIn = 'keepSignedIn';

  // Save the keepSignedIn preference
  static Future<void> setKeepSignedIn(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyKeepSignedIn, value);
  }

  // Get the keepSignedIn preference
  static Future<bool> getKeepSignedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyKeepSignedIn) ?? false; // Ensure a bool is always returned
  }

  // Clear the keepSignedIn preference
  static Future<void> clearKeepSignedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyKeepSignedIn);
  }
}
