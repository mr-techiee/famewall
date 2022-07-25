
import 'package:shared_preferences/shared_preferences.dart';

class PreferenceUtils {
  static Future<SharedPreferences> get _instance async => _prefsInstance ??= await SharedPreferences.getInstance();
  static SharedPreferences? _prefsInstance;

  // call this method from iniState() function of mainApp().
  static Future<SharedPreferences> init() async {
    _prefsInstance = await _instance;
    return _prefsInstance!;
  }

  static String getString(String key, String defValue) {
    return _prefsInstance==null?"":_prefsInstance!.getString(key) ?? defValue ?? "";
  }
  static bool? getBool(String key) {
    return _prefsInstance!.getBool(key)??false;
  }
  static Future<bool> setBool(String key, bool value) async {
    var prefs = await _instance;
    return prefs.setBool(key, value);
  }
  static Future<bool> setString(String key, String value) async {
    var prefs = await _instance;
    return prefs.setString(key, value);
  }
}