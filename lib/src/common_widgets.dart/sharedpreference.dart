import 'package:shared_preferences/shared_preferences.dart';

class Preference {
  static SharedPreferences? _sharedPreferences;

  //INITIALIZE
  static Future<void> init() async {
    _sharedPreferences = await SharedPreferences.getInstance();
  }

  //SETTER
  static Future<void> setString(String key, String value) async {
    await _sharedPreferences?.setString(key, value);
  }

  static Future<void> setInt(String key, int value) async {
    await _sharedPreferences?.setInt(key, value);
  }

  static Future<void> setBool(String key, bool value) async {
    await _sharedPreferences?.setBool(key, value);
  }

  static Future<void> setDouble(String key, double value) async {
    await _sharedPreferences?.setDouble(key, value);
  }

  //REMOVE
  static Future<void> remove(String key) async {
    await _sharedPreferences?.remove(key);
  }

  //GETTER
  static bool? getBool(String key) {
    return _sharedPreferences?.getBool(key);
  }

  static String? getString(String key) {
    return _sharedPreferences?.getString(key);
  }

  static int? getInt(String key) {
    return _sharedPreferences?.getInt(key);
  }

  static double? getDouble(String key) {
    return _sharedPreferences?.getDouble(key);
  }

  //CLEAR ALL
  static Future<void> clearPreferences() async {
    await _sharedPreferences?.clear();
  }

  static Future<void> clearExcept(String keepKey) async {
    final keys = _sharedPreferences?.getKeys() ?? {};

    for (var key in keys) {
      if (key != keepKey) {
        await _sharedPreferences?.remove(key);
      }
    }
  }
}
