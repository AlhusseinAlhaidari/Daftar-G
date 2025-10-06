import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/app_settings.dart';

class SettingsService {
  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;
  SettingsService._internal();

  static const String _settingsKey = 'app_settings';
  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<AppSettings> loadSettings() async {
    if (_prefs == null) await init();
    
    final settingsJson = _prefs!.getString(_settingsKey);
    if (settingsJson != null) {
      try {
        final map = json.decode(settingsJson) as Map<String, dynamic>;
        return AppSettings.fromMap(map);
      } catch (e) {
        // في حالة حدوث خطأ، إرجاع الإعدادات الافتراضية
        return const AppSettings();
      }
    }
    
    return const AppSettings();
  }

  Future<bool> saveSettings(AppSettings settings) async {
    if (_prefs == null) await init();
    
    try {
      final settingsJson = json.encode(settings.toMap());
      return await _prefs!.setString(_settingsKey, settingsJson);
    } catch (e) {
      return false;
    }
  }

  Future<bool> clearSettings() async {
    if (_prefs == null) await init();
    return await _prefs!.remove(_settingsKey);
  }
}
