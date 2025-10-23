import 'package:shared_preferences/shared_preferences.dart';

class SessionStore {
  static const _kRemember = 'remember_me';
  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  bool get isBootRemembered => _prefs?.getBool(_kRemember) ?? false;

  Future<void> setRemembered(bool value) async {
    await _prefs?.setBool(_kRemember, value);
  }

  Future<bool> get isRemembered async => _prefs?.getBool(_kRemember) ?? false;
}
