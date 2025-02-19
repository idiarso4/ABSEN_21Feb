import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {
  static setInt(String key, int value) async {
    final pref = await SharedPreferences.getInstance();
    pref.setInt(key, value);
  }

  static setString(String key, String value) async {
    final pref = await SharedPreferences.getInstance();
    pref.setString(key, value);
  }

  static getInt(String key) async {
    final pref = await SharedPreferences.getInstance();
    return pref.getInt(key);
  }

  static getString(String key) async {
    final pref = await SharedPreferences.getInstance();
    return pref.getString(key);
  }

  static logout() async {
    final pref = await SharedPreferences.getInstance();
    return pref.clear();
  }

  static Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('role');
  }

  static Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('email');
  }

  static Future<String?> getPhone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('phone');
  }

  static Future<String?> getNip() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('nip');
  }

  static Future<String?> getAddress() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('address');
  }
}
