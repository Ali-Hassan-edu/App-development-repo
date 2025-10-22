import 'package:shared_preferences/shared_preferences.dart';

class SessionStore {
  static const _rememberKey = 'remember_me';
  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  Future<void> setRemembered(bool value) async {
    await _prefs?.setBool(_rememberKey, value);
  }

  Future<bool> get isRemembered async {
    return _prefs?.getBool(_rememberKey) ?? false;
  }
}
