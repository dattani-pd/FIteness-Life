import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {
  SharedPreferences? prefs;


  Future getSharedPreferencesInstance() async {
    prefs = await SharedPreferences.getInstance();
  }

  Future<void> _ensurePrefs() async {
    if (prefs == null) {
      prefs = await SharedPreferences.getInstance();
    }
  }

  Future storeBoolPrefData(String key, bool res) async {
    await _ensurePrefs();
    await prefs?.setBool(key, res);
  }

  Future storePrefData(String key, String res) async {
    await _ensurePrefs();
    await prefs?.setString(key, res);
  }

  Future<String?> getPrefData(String key) async {
    await _ensurePrefs();
    return prefs?.getString(key);
  }

  Future<bool> retrievePrefBoolData(String key) async {
    await _ensurePrefs();
    return prefs?.getBool(key) ?? false;
  }

  Future clearPrefData() async {
    await _ensurePrefs();
    await prefs?.clear();
  }

  Future clearPrefDataByKey(String key) async {
    await _ensurePrefs();
    await prefs?.remove(key);
  }

  /// Clears only session data (userId, email, role, userName, isApproved). Keeps remembered email, theme, cache.
  Future clearSessionData() async {
    await _ensurePrefs();
    for (final key in ['userId', 'email', 'role', 'userName', 'isApproved']) {
      await prefs?.remove(key);
    }
  }
}

SharedPreferencesHelper sharedPreferencesHelper = SharedPreferencesHelper();
