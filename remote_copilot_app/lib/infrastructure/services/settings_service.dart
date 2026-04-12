import 'package:flutter/material.dart';
import 'package:remote_copilot_app/core/config/app_defaults.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class SettingsService {
  Future<String> loadBaseUrl();

  Future<ThemeMode> loadThemeMode();

  Future<void> saveBaseUrl(String value);

  Future<void> saveThemeMode(ThemeMode value);
}

class SharedPreferencesSettingsService implements SettingsService {
  static const _baseUrlKey = 'remote_copilot.base_url';
  static const _themeModeKey = 'remote_copilot.theme_mode';

  @override
  Future<String> loadBaseUrl() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(_baseUrlKey) ?? AppDefaults.defaultApiBaseUrl;
  }

  @override
  Future<ThemeMode> loadThemeMode() async {
    final preferences = await SharedPreferences.getInstance();
    final storedValue = preferences.getString(_themeModeKey);

    return switch (storedValue) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  @override
  Future<void> saveBaseUrl(String value) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_baseUrlKey, value);
  }

  @override
  Future<void> saveThemeMode(ThemeMode value) async {
    final preferences = await SharedPreferences.getInstance();
    final storedValue = switch (value) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };

    await preferences.setString(_themeModeKey, storedValue);
  }
}
